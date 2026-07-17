---
name: validapp-content
description: Usa este skill para currículo escolar chileno y temarios de exámenes libres en ValidApp — cursos, asignaturas, ejes curriculares, unidades, objetivos de aprendizaje, habilidades y cobertura de contenidos. Debe delegar el trabajo al agente validapp-curriculum-specialist.
context: fork
agent: validapp-curriculum-specialist
---

# validapp-content

Este skill delega tareas de currículo y contenido educativo de ValidApp al agente `validapp-curriculum-specialist`, que define el flujo de trabajo obligatorio, las validaciones, restricciones y el formato de respuesta completos.

Instrucción del usuario: $ARGUMENTS

## Procedimiento

1. Pasar la instrucción ($ARGUMENTS) al agente `validapp-curriculum-specialist` para que ejecute su flujo de trabajo obligatorio (lectura de `CLAUDE.md`, `git status`, estructura curricular existente, migraciones y tipos sin modificarlos, identificación de la fuente oficial).
2. Clasificar la instrucción según los verbos que use (ver abajo) antes de actuar.
3. Exigir fuente verificable (documento, año, versión, URL, página o sección) para cualquier dato tratado como oficial; si no puede verificarse, marcarlo explícitamente como no verificado.
4. Si la instrucción corresponde a tablas/migraciones/RLS, a diseño visual, o a redacción de preguntas/ensayos, no ejecutarla: indicarlo y recomendar `/validapp-db`, `/validapp-ui` o `/validapp-assessments` según corresponda.
5. Devolver al contexto principal un resumen estructurado de hallazgos o cambios, siguiendo el formato de respuesta del agente (análisis o preparación de datos, según corresponda).

## Clasificación de la orden

- **"Analiza", "revisa" o "compara"** → solo lectura. No modificar archivos. Identificar estructura, cobertura, errores y faltantes, con evidencia (página o sección de origen).
- **"Diseña", "organiza" o "propón"** → proponer estructura curricular (curso, asignatura, eje, unidad, objetivo) y señalar qué decisiones requieren validación pedagógica. No crear archivos salvo petición expresa.
- **"Estructura", "prepara", "convierte" o "implementa localmente"** → puede crear archivos locales de importación (JSON/CSV/SQL) respetando el modelo de datos aprobado. No modifica el esquema de Supabase ni carga nada remoto. Valida antes de entregar e informa registros creados/omitidos/marcados para revisión.
- **"Carga", "publica", "sincroniza" o "aplica"** → detenerse antes de tocar Supabase, mostrar proyecto/entorno, cantidad de registros, tablas involucradas, nuevos/actualizados, duplicados, estrategia de reversión, validaciones y comando exacto, y solicitar autorización explícita. Una autorización para crear archivos locales nunca autoriza una carga remota.

## Recordatorios

- Seguir las reglas de `CLAUDE.md` (trabajar por etapas pequeñas, no eliminar archivos sin autorización, confirmar el dominio de datos afectado).
- No inventar objetivos, códigos, temarios ni citas; separar siempre texto oficial de resumen simplificado.
- Nunca crear o modificar migraciones, ejecutar SQL remoto, modificar RLS, ni cargar contenido a Supabase — esas acciones son de `/validapp-db`.
- Nunca diseñar o implementar pantallas — eso es de `/validapp-ui`.
- Nunca redactar preguntas ni generar ensayos — eso es de `/validapp-assessments`.
- Una auditoría de cobertura curricular no equivale a autorización para cargar o corregir datos.
