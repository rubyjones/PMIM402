model_board <- board_folder("models/", versioned = TRUE)

ctrl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = TRUE
)

set.seed(999)

lr_caret <- train(
  churn ~.,
  data = churn_train,
  method = "glmnet",
  trControl = ctrl,
  metric = "ROC",
  tuneGrid = expand.grid(
    alpha = c(0, 0.5, 1),
    lambda = c(0.001, 0.01, 0.1, 1)
  )
)

lr_caret


# random forest model
rf_caret <- train(
  churn ~.,
  data = churn_train,
  method = "rf",
  trControl = ctrl,
  metric = "ROC",
  tuneGrid = expand.grid(
    mtry = c(2,4,6)
  )
)
rf_caret

# create a 'league table' of model results using pins package
pin_write(
  model_board,
  lr_caret,
  name = "churn_model_caret",
  metadata = list(
    method = "lr",
    cv_roc = max(lr_caret$results$ROC),
    cv_sens = max(lr_caret$results$Sens),
    cv_spec =  max(lr_caret$results$Spec),
    best_tune_str = paste0(
      "alpha: ", lr_caret$bestTune$alpha,
      ", lambda:  ", lr_caret$bestTune$lambda
    ),
    ntrain = nrow(churn_train)
  )
)


pin_write(
  model_board,
  rf_caret,
  name = "churn_model_caret",
  metadata = list(
    method = "rf",
    cv_roc = max(rf_caret$results$ROC),
    cv_sens = max(rf_caret$results$Sens),
    cv_spec =  max(rf_caret$results$Spec),
    best_tune_str = paste0(
      "mtry:  ", rf_caret$bestTune$mtry
    ),
    ntrain = nrow(churn_train)
  )
)

versions <- pin_versions(model_board, "churn_model_caret")

league_table <- map_dfr(versions$version, function(v) {
  meta <- pin_meta(model_board, "churn_model_caret", version = v)
  tibble(
    version = v,
    method = meta$user$method,
    cv_roc = meta$user$cv_roc,
    cv_sens = meta$user$cv_sens,
    cv_spec = meta$user$cv_spec,
    best_tune_str = meta$user$best_tune_str,
    n_train = meta$user$n_train
  )
})

saveRDS(league_table, "league_table.rdata")