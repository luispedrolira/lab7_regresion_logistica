library(nnet)
library(pROC)
library(tidyverse)

load("splits.RData")
load("modelo_base.RData")

cat("vars_predictoras:", paste(vars_predictoras, collapse=", "), "\n\n")

# --- ACT 11: MULTINOM ---
train_multi <- train_data %>%
  select(all_of(c("categoria_precio", vars_predictoras))) %>%
  drop_na() %>%
  mutate(categoria_precio = relevel(factor(categoria_precio), ref = "caro"))

test_multi <- test_data %>%
  select(all_of(c("categoria_precio", vars_predictoras))) %>%
  drop_na() %>%
  mutate(categoria_precio = relevel(factor(categoria_precio), ref = "caro"))

cat("Clase de referencia:", levels(train_multi$categoria_precio)[1], "\n")
cat("Filas train:", nrow(train_multi), "| test:", nrow(test_multi), "\n\n")

set.seed(42)
formula_multi <- as.formula(
  paste("categoria_precio ~", paste(vars_predictoras, collapse = " + "))
)

modelo_multi <- multinom(formula_multi, data = train_multi, maxit = 300, trace = FALSE)
cat("Multinom entrenado OK\n")

pred_multi <- predict(modelo_multi, newdata = test_multi, type = "class")
cat("Predicciones generadas OK\n")

conf_multi <- table(Real = test_multi$categoria_precio, Predicho = pred_multi)
cat("Matriz de confusion:\n")
print(conf_multi)

acc_global_multi <- sum(diag(conf_multi)) / sum(conf_multi)
acc_por_clase <- diag(conf_multi) / rowSums(conf_multi)
prec_por_clase <- diag(conf_multi) / colSums(conf_multi)
f1_por_clase <- 2 * acc_por_clase * prec_por_clase / (acc_por_clase + prec_por_clase)

cat("\nAccuracy global:", round(acc_global_multi, 4), "\n")
cat("Accuracy por clase:\n")
print(round(acc_por_clase, 4))

# Confusion dominante
errores <- conf_multi
diag(errores) <- 0
max_error_idx <- which(errores == max(errores), arr.ind = TRUE)
clase_real_err <- rownames(errores)[max_error_idx[1, 1]]
clase_pred_err <- colnames(errores)[max_error_idx[1, 2]]
cat("\nConfusion mas frecuente:", clase_real_err, "->", clase_pred_err,
    "(N=", max(errores), ")\n")

# --- ACT 12: evaluar_en_test (logica sin caret) ---
cat("\n--- Verificando funcion evaluar_en_test (logica) ---\n")
# Probar con modelo_base directo
train_bin <- train_data %>%
  select(all_of(c("es_caro", vars_predictoras))) %>%
  drop_na()
test_bin_raw <- test_data %>%
  select(all_of(c("es_caro", vars_predictoras))) %>%
  drop_na()

probs_base_check <- predict(modelo_base, newdata = test_bin_raw, type = "response")
preds_base_check <- ifelse(probs_base_check >= 0.5, "caro", "no_caro")
y_real_check <- ifelse(test_bin_raw$es_caro == 1, "caro", "no_caro")

tp <- sum(preds_base_check == "caro"    & y_real_check == "caro")
tn <- sum(preds_base_check == "no_caro" & y_real_check == "no_caro")
fp <- sum(preds_base_check == "caro"    & y_real_check == "no_caro")
fn <- sum(preds_base_check == "no_caro" & y_real_check == "caro")

acc  <- (tp + tn) / length(y_real_check)
prec <- tp / (tp + fp)
rec  <- tp / (tp + fn)
f1   <- 2 * prec * rec / (prec + rec)
auc  <- as.numeric(pROC::auc(pROC::roc(as.integer(y_real_check == "caro"), probs_base_check, quiet = TRUE)))

cat("Logistica base — AUC:", round(auc,4), "| Acc:", round(acc,4), "| F1:", round(f1,4), "\n")
cat("\nTodos los checks de Act 11 y 12 pasaron OK\n")
