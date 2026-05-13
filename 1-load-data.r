data(mlc_churn)
head(mlc_churn)
set.seed(999)

# create train and test data
bound <- nrow(mlc_churn)*0.75
mlc_churn <- mlc_churn[sample(nrow(mlc_churn)), ]
churn_train <- mlc_churn[1:bound,]
churn_test <- mlc_churn[(bound + 1): nrow(mlc_churn), ]

saveRDS(churn_test, "churn_test.rds")
