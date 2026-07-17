---
name: validapp-assessments
description: Usa este skill para banco de preguntas, alternativas y explicaciones, diagnósticos, ensayos, plantillas y reglas de selección automática, y estadísticas de desempeño de preguntas en ValidApp. Debe delegar el trabajo al agente validapp-assessment-engineer.
context: fork
agent: validapp-assessment-engineer
---

# validapp-assessments

Este skill delega tareas de banco de preguntas, ensayos y lógica evaluativa de ValidApp al agente `validapp-assessment-engineer`, que define el flujo de trabajo obligatorio, los requisitos de las preguntas, las reglas del generador automático, las restricciones y el formato de respuesta completos.

Instrucción del usuario: $ARGUMENTS

## Procedimiento

1. Pasar la instrucción ($ARGUMENTS) al agente `validapp-assessment-engineer` para que ejecute su flujo de trabajo obligatorio (lectura de `CLAUDE.md`, `git status`, migraciones/tipos y estructura curricular sin modificarlos, localización de la lógica actual de preguntas/diagnósticos/respuestas).
2. Clasificar la instrucción según los verbos que use (ver abajo) antes de actuar.
3. Si la instrucción requiere tablas/migraciones/RLS, estructura curricular/fuentes oficiales, o diseño visual, no ejecutarla: indicarlo y recomendar `/validapp-db`, `/validapp-content` o `/validapp-ui` según corresponda.
4. Devolver al contexto principal un resumen estructurado de hallazgos o cambios, siguiendo el formato de respuesta del agente (auditoría o implementación, según corresponda).

## Clasificación de la orden

- **"Analiza", "revisa", "audita" o "evalúa"** → solo lectura. No modificar archivos ni Supabase. Revisar calidad, cobertura, duplicados, dificultad y alineación curricular.
- **"Diseña", "propón" o "planifica"** → diseñar reglas, plantillas o algoritmos con criterios y casos límite. No crear archivos salvo solicitud expresa.
- **"Genera" o "redacta preguntas"** → crear solo borradores locales marcados como `draft`, exigiendo curso/asignatura/objetivo aprobado y fuente curricular verificable. Nunca considerarlas aprobadas ni publicarlas; exige revisión humana pedagógica. Informar cantidad generada, rechazada y pendiente.
- **"Implementa" o "corrige localmente"** → puede modificar lógica local de selección/evaluación y crear pruebas automatizadas. No crea ni altera tablas ni aplica migraciones. Debe preservar diagnósticos y lecciones existentes, y comprobar lint/pruebas/build.
- **"Publica", "asigna", "carga" o "genera en producción"** → detenerse antes de cualquier acción remota o de asignación real a estudiantes, mostrar proyecto/entorno, preguntas/ensayo involucrados, cantidad de registros, reglas aplicadas, validaciones, consecuencias para estudiantes, reversión y procedimiento exacto, y solicitar autorización explícita. Una autorización para generar borradores o archivos locales nunca autoriza publicar o cargar en producción.

## Recordatorios

- Seguir las reglas de `CLAUDE.md` (trabajar por etapas pequeñas, no eliminar archivos sin autorización, confirmar el dominio de datos afectado).
- Nunca inventar códigos u objetivos de aprendizaje; toda pregunta debe basarse en una fuente curricular verificable.
- Nunca crear o modificar migraciones, ejecutar SQL remoto, modificar RLS, ni hacer `git push` o desplegar — esas acciones no corresponden a este agente.
- Nunca alterar resultados históricos ni eliminar preguntas usadas en intentos anteriores.
- Nunca exportar respuestas identificables de estudiantes ni usar datos reales en pruebas.
- Una auditoría del banco de preguntas no equivale a autorización para publicar o corregir contenido.
