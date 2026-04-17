# Plan de Trabajo – Lab 6: Regresión Logística
> **Curso:** CC3074 – Minería de Datos | **Stack:** R / RStudio / RMarkdown  
> **Regla global:** Todos usan el mismo seed y splits definidos por P1 en la Entrega 1.

---

## Estructura General

| Entrega | Fecha | Actividades |
|---------|-------|-------------|
| **Pasaporte** | 17 de abril | Actividades 1 – 6 |
| **Final** | 19 de abril | Actividades 7 – 12 |

---

## Distribución por Entrega

### Entrega 1 – Pasaporte (Act. 1–6)

| Persona | Actividades | Qué cubre |
|---------|-------------|-----------|
| **P1** | Act. 1, 2 | Variables dicotómicas + Train/Test split |
| **P2** | Act. 3, 4 | Modelo logístico binario + Análisis del modelo |
| **P3** | Act. 5, 6 | Evaluación en test + Overfitting / Curvas de aprendizaje |

> ⚠️ **P1 debe terminar primero.** P2 y P3 dependen de sus splits y variables.

### Entrega 2 – Final (Act. 7–12)

| Persona | Actividades | Qué cubre |
|---------|-------------|-----------|
| **P1** | Act. 7, 8 | Tuneo con regularización + Matriz de confusión |
| **P2** | Act. 9, 10 | Ajuste de umbral (Youden) + Selección AIC/BIC |
| **P3** | Act. 11, 12 | Modelo multiclase + Comparación de algoritmos |

---

# ENTREGA 1 — Pasaporte (17 de abril)

---

## P1 – Actividades 1 y 2
### Variables Dicotómicas + Train/Test Split

---

### Actividad 1 — Crear variables dicotómicas y multiclase

**Qué hacer:**
Cargar el dataset `listings.RData` y crear dos variables nuevas a partir de `price`:
- Una variable **binaria** llamada `es_caro` (1 = caro, 0 = no caro)
- Una variable **multiclase** de 3 niveles: `economico`, `medio`, `caro`

**Cómo hacerlo:**
- Primero limpiar `price` si viene como texto con símbolos y convertirla a numérico.
- Definir los umbrales usando los percentiles 33 y 66 del precio. Esto garantiza clases balanceadas.
- La variable binaria se construye marcando como `caro` todo lo que supere el percentil 66.
- La variable multiclase usa ambos percentiles para dividir en tres rangos.
- Justificar en el informe por qué se usaron percentiles y no umbrales fijos de negocio.

**Qué documentar:**
- Distribución del precio antes y después de limpiar
- Valores exactos de los percentiles obtenidos
- Proporción de observaciones en cada clase para verificar balance

---

### Actividad 2 — Train/Test Split

**Qué hacer:**
Dividir el dataset en conjunto de entrenamiento y prueba, y exportar ese split para que todos lo usen.

**Cómo hacerlo:**
- Fijar un seed global que todos los integrantes deben respetar sin excepción.
- Usar una división estratificada que respete la proporción de clases, con una proporción de 75% train y 25% test.
- Exportar los conjuntos como un archivo `.RData` compartido que P2 y P3 deben cargar directamente sin regenerar.

**Qué documentar:**
- Justificación de la proporción 75/25
- Verificar que el balance de clases se conserva en ambos conjuntos
- Tamaño en filas y columnas de cada conjunto

**Output crítico:** archivo `splits.RData` con `train_data`, `test_data` y el seed documentado en el `.Rmd`.

---

## P2 – Actividades 3 y 4
### Modelo Logístico Binario + Análisis del Modelo

> **Prerequisito:** Cargar `splits.RData` entregado por P1.

---

### Actividad 3 — Modelo Logístico Binario con Validación Cruzada

**Qué hacer:**
Entrenar un modelo de regresión logística binaria sobre `es_caro` usando los datos de train, y validarlo con validación cruzada.

**Cómo hacerlo:**
- Seleccionar las variables predictoras con criterio: no incluir todo el dataset sin análisis previo. Eliminar variables con muchos NAs, identificadores, o que sean redundantes con `price`.
- Entrenar el modelo con `glm` usando familia `binomial`.
- Aplicar validación cruzada de 10 pliegues para estimar el AUC de forma más confiable que con una sola división.
- Usar umbral de decisión 0.5 por defecto en esta etapa.

**Qué documentar:**
- Variables seleccionadas y criterio de selección
- AUC promedio obtenido en validación cruzada
- Accuracy en train con umbral 0.5

---

### Actividad 4 — Análisis del Modelo

**Qué hacer:**
Analizar la calidad estadística del modelo: qué variables son significativas, si hay multicolinealidad, y qué significan los coeficientes.

**Cómo hacerlo:**
- Revisar el resumen del modelo: p-values, z-values y significancia de cada variable.
- Calcular el VIF (Variance Inflation Factor) para detectar multicolinealidad. Si alguna variable tiene VIF mayor a 5, documentar y decidir si se elimina o se justifica mantenerla.
- Calcular los odds ratios exponenciando los coeficientes para interpretarlos en lenguaje de negocio.

**Qué documentar:**
- Tabla de coeficientes con su significancia
- Variables con VIF problemático y la decisión tomada
- Interpretación de al menos 3 odds ratios en lenguaje de negocio
- Variables no significativas: ¿se eliminan o se mantienen y por qué?

**Output crítico:** objeto `modelo_base` exportado para que P3 lo use en la Actividad 5.

---

## P3 – Actividades 5 y 6
### Evaluación en Test + Overfitting y Curvas de Aprendizaje

> **Prerequisito:** Cargar `splits.RData` de P1 y `modelo_base` de P2.

---

### Actividad 5 — Evaluación en Test

**Qué hacer:**
Evaluar el desempeño del modelo base sobre el conjunto de prueba usando múltiples métricas.

**Cómo hacerlo:**
- Generar probabilidades predichas sobre `test_data` y aplicar umbral 0.5 para obtener clases predichas.
- Calcular las métricas principales: Accuracy, Precision, Recall, F1 y AUC-ROC.
- Graficar la curva ROC e indicar el AUC en el título o anotación del gráfico.
- Comparar el AUC obtenido aquí con el AUC de validación cruzada de P2 para detectar diferencias.

**Qué documentar:**
- Tabla de métricas en test
- Gráfico de curva ROC con análisis escrito
- Comparación AUC en CV vs AUC en test: ¿son similares o hay señales de overfitting?

---

### Actividad 6 — Overfitting y Curvas de Aprendizaje

**Qué hacer:**
Determinar si el modelo sufre de overfitting o underfitting generando curvas de aprendizaje.

**Cómo hacerlo:**
- Entrenar el modelo repetidamente usando subconjuntos crecientes de `train_data` (desde 10% hasta 100% en incrementos de 10%).
- Para cada tamaño de subconjunto, registrar el accuracy sobre ese subconjunto y sobre el `test_data` completo.
- Graficar ambas curvas (train y test) en función del porcentaje de datos usados.

**Cómo interpretar el gráfico:**
- Gap grande entre train y test que no cierra → overfitting
- Ambas curvas convergen en valores bajos → underfitting
- Las curvas se acercan progresivamente conforme aumentan los datos → comportamiento saludable

**Qué documentar:**
- Gráfico de curvas de aprendizaje con análisis escrito debajo
- Diagnóstico claro: overfitting, underfitting, o comportamiento esperado
- Recomendación: ¿el modelo necesita regularización, más datos, o menos variables?

**Output crítico:** objetos `probs_test` y `roc_obj` exportados para que P2 los use en la Entrega 2.

---

# ENTREGA 2 — Final (19 de abril)

---

## P1 – Actividades 7 y 8
### Tuneo con Regularización + Matriz de Confusión

> **Prerequisito:** `splits.RData` y `modelo_base` de la Entrega 1.

---

### Actividad 7 — Tuneo con Regularización

**Qué hacer:**
Aplicar regularización al modelo logístico para controlar overfitting y comparar contra el modelo base.

**Cómo hacerlo:**
- Probar tres variantes de regularización usando la librería `glmnet`: Lasso (alpha=1), Ridge (alpha=0) y Elastic Net (alpha intermedio).
- Para cada variante, usar validación cruzada interna para encontrar el valor óptimo de lambda (el parámetro de penalización).
- Comparar el AUC en test de los tres modelos regularizados contra el modelo base de la Entrega 1.
- Observar qué variables eliminó Lasso (coeficiente = 0) y analizar si tiene sentido en el contexto del negocio.

**Qué documentar:**
- Lambda óptimo encontrado para cada variante y cómo se seleccionó
- Tabla comparativa de AUC: Base vs Lasso vs Ridge vs Elastic Net
- Variables que Lasso eliminó y si esa eliminación es razonable
- Conclusión: ¿la regularización mejoró el modelo? ¿cuál variante es preferible y por qué?

---

### Actividad 8 — Matriz de Confusión y Métricas Completas

**Qué hacer:**
Generar matrices de confusión para el modelo base y el mejor modelo regularizado, y comparar sus métricas en detalle.

**Cómo hacerlo:**
- Aplicar umbral 0.5 a las probabilidades predichas de cada modelo.
- Generar la matriz de confusión completa para cada uno con TP, TN, FP y FN.
- Calcular y tabular: Accuracy, Sensitivity, Specificity, Precision, F1 y AUC.

**Qué documentar:**
- Matrices de confusión comparadas (base vs regularizado)
- Análisis del tipo de error más frecuente en cada modelo
- Reflexión de negocio: para SmartStay, ¿qué es más costoso, predecir como caro algo que no lo es, o no detectar una propiedad cara? Esto justifica qué métrica priorizar.

---

## P2 – Actividades 9 y 10
### Ajuste de Umbral + Selección de Modelo (AIC/BIC)

> **Prerequisito:** `splits.RData`, `modelo_base` y `roc_obj` exportado por P3 en la Entrega 1.

---

### Actividad 9 — Ajuste de Umbral con Índice de Youden

**Qué hacer:**
Encontrar el umbral de clasificación óptimo que maximice la utilidad del modelo, en lugar de usar 0.5 por defecto.

**Cómo hacerlo:**
- Usar el objeto `roc_obj` de la Entrega 1 para calcular el umbral que maximiza el índice de Youden, definido como `Sensitivity + Specificity - 1`.
- Aplicar ese umbral a las probabilidades predichas en test y generar una nueva matriz de confusión.
- Comparar directamente la matriz con umbral 0.5 vs la matriz con umbral Youden.

**Qué documentar:**
- Valor del umbral óptimo encontrado
- Cómo cambian Sensitivity y Specificity con el nuevo umbral respecto al 0.5
- Justificación de negocio: ¿conviene priorizar sensibilidad o especificidad para SmartStay?
- Conclusión: ¿el umbral Youden mejora el modelo para este caso de uso?

---

### Actividad 10 — Selección de Modelo con AIC y BIC

**Qué hacer:**
Comparar variantes del modelo logístico usando criterios de información para seleccionar la especificación más adecuada.

**Cómo hacerlo:**
- Ajustar al menos tres modelos con diferente cantidad de variables: uno completo, uno reducido manualmente, y uno generado por selección stepwise automática.
- Calcular AIC y BIC para cada uno y comparar.
- Para el stepwise, usar BIC como penalización en la selección automática, ya que BIC penaliza más la complejidad que AIC.

**Qué documentar:**
- Tabla comparativa con AIC y BIC de cada modelo evaluado
- Explicación de la diferencia entre AIC y BIC: BIC tiende a seleccionar modelos más simples
- Modelo ganador elegido y justificación clara
- Si el modelo stepwise difiere del modelo base original, analizar qué variables añadió o eliminó y por qué

---

## P3 – Actividades 11 y 12
### Modelo Multiclase + Comparación de Algoritmos

> **Prerequisito:** `splits.RData` con `categoria_precio` de P1 Entrega 1.

---

### Actividad 11 — Modelo Multiclase

**Qué hacer:**
Entrenar un modelo de regresión logística multinomial para predecir las tres categorías de precio (`economico`, `medio`, `caro`).

**Cómo hacerlo:**
- Usar regresión logística multinomial con la función `multinom` de la librería `nnet`, que extiende la regresión logística binaria al caso de más de dos clases.
- Usar los mismos predictores que se usaron en el modelo binario para mantener comparabilidad entre ambos modelos.
- La clase de referencia será la primera en orden alfabético. Documentar cuál es y por qué importa al interpretar los coeficientes.
- Evaluar con matriz de confusión multiclase en test.

**Qué documentar:**
- Clase de referencia del modelo y su implicación en la interpretación
- Matriz de confusión multiclase: identificar qué clase se confunde más con cuál
- Accuracy por clase y accuracy global
- Análisis: ¿el modelo distingue bien las tres categorías o hay clases que colapsan entre sí?

---

### Actividad 12 — Comparación con Otros Algoritmos

**Qué hacer:**
Comparar el modelo de regresión logística contra cuatro algoritmos adicionales sobre el mismo problema binario, usando las mismas condiciones de evaluación.

**Algoritmos a comparar:**
1. Árbol de regresión (`rpart`)
2. Random Forest (`rf`)
3. Naive Bayes (`naive_bayes`)
4. KNN (`knn`)

**Cómo hacerlo:**
- Usar el mismo esquema de validación cruzada de 10 pliegues para todos los modelos, con el mismo seed global.
- Usar `caret` como framework unificado para que los resultados sean directamente comparables.
- Para KNN, evaluar al menos 4 valores de k y reportar el mejor encontrado.
- Consolidar todas las métricas en una sola tabla y generar un gráfico comparativo con intervalos de confianza.

**Qué documentar:**
- Tabla comparativa: AUC, Accuracy y F1 para cada algoritmo
- Gráfico de comparación con intervalos de confianza entre modelos
- Análisis: ¿qué modelo gana y por qué? ¿hay trade-offs entre interpretabilidad y performance?
- Recomendación final para SmartStay: ¿qué modelo implementarían en producción y por qué?

---

# Flujo de Dependencias

```
P1-E1 (splits.RData + variables)
        │
        ├──► P2-E1 (modelo_base + análisis)
        │           │
        │           └──► P3-E1 (evaluación + curvas) ──► exporta probs_test, roc_obj
        │
        ├──► P1-E2 (tuneo + matrices)          consume modelo_base
        ├──► P2-E2 (umbral + AIC/BIC)          consume roc_obj de P3-E1
        └──► P3-E2 (multiclase + comparación)  consume categoria_precio de P1-E1
```

---

# Checklist de Entregables

### Entrega 1 – Pasaporte

**P1**
- [ ] `price` limpio y convertido a numérico
- [ ] `es_caro` creado con umbrales justificados
- [ ] `categoria_precio` creado con 3 niveles
- [ ] `splits.RData` exportado y compartido con el equipo
- [ ] Balance de clases verificado en train y test

**P2**
- [ ] Variables predictoras seleccionadas con criterio documentado
- [ ] Modelo `glm` entrenado sobre `train_data`
- [ ] Validación cruzada 10-fold ejecutada y AUC reportado
- [ ] VIF calculado para todas las variables
- [ ] Odds ratios interpretados en lenguaje de negocio
- [ ] `modelo_base` exportado para P3

**P3**
- [ ] Métricas en test calculadas (Accuracy, Precision, Recall, F1, AUC)
- [ ] Curva ROC graficada y analizada con texto
- [ ] Curvas de aprendizaje generadas e interpretadas con texto
- [ ] Diagnóstico de overfitting/underfitting documentado
- [ ] `probs_test` y `roc_obj` exportados para Entrega 2

---

### Entrega 2 – Final

**P1**
- [ ] Tres variantes regularizadas entrenadas (Lasso, Ridge, Elastic Net)
- [ ] Lambda óptimo documentado para cada variante
- [ ] Tabla comparativa de AUC base vs regularizados
- [ ] Matrices de confusión generadas y comparadas con análisis
- [ ] Reflexión sobre errores tipo I y II en contexto de negocio

**P2**
- [ ] Umbral Youden calculado y justificado
- [ ] Matrices comparadas: umbral 0.5 vs umbral Youden
- [ ] Al menos 3 modelos comparados con AIC y BIC en tabla
- [ ] Modelo ganador seleccionado con justificación clara

**P3**
- [ ] Modelo multinomial entrenado y clase de referencia documentada
- [ ] Matriz de confusión multiclase analizada por clase
- [ ] Los 5 algoritmos comparados bajo el mismo esquema de CV
- [ ] Tabla y gráfico comparativo con análisis escrito
- [ ] Recomendación final para SmartStay redactada