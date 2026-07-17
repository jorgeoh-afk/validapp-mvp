---
name: validapp-db
description: Usa este skill para tareas de Supabase y PostgreSQL en ValidApp — tablas, relaciones, migraciones, claves e índices, RLS, funciones y triggers, auditoría de esquema remoto vs. repositorio, tipos TypeScript derivados, y evolución del modelo curricular, banco de preguntas y ensayos. Debe delegar el trabajo al agente validapp-db-engineer.
context: fork
agent: validapp-db-engineer
---

# validapp-db

Este skill delega tareas de base de datos y Supabase de ValidApp al agente `validapp-db-engineer`, que define el flujo de trabajo obligatorio, las restricciones y el formato de respuesta completos.

Instrucción del usuario: $ARGUMENTS

## Procedimiento

1. Pasar la instrucción ($ARGUMENTS) al agente `validapp-db-engineer` para que ejecute su flujo de trabajo obligatorio (lectura de `CLAUDE.md`, `git status`, `supabase/config.toml`, `supabase/migrations/`, consultas relacionadas).
2. Clasificar la instrucción según los verbos que use (ver abajo) antes de actuar.
3. Respetar las restricciones y reglas de seguridad de datos definidas en el agente.
4. Devolver al contexto principal un resumen de hallazgos o cambios, siguiendo el formato de respuesta del agente (auditoría o implementación, según corresponda).

## Clasificación de la orden

- **"Analiza", "revisa", "audita", "comprueba" o "compara"** → solo lectura. No modificar archivos ni Supabase. Entregar hallazgos, riesgos y recomendaciones con evidencia.
- **"Diseña", "propón" o "planifica"** → entregar propuesta de tablas, relaciones o migraciones y su impacto. No crear archivos ni ejecutar SQL salvo petición expresa.
- **"Implementa", "crea la migración" o "corrige localmente"** → puede crear una migración local nueva (nunca modificar una histórica) y actualizar consultas/tipos locales. No aplica nada a Supabase remoto. Ejecuta verificaciones locales disponibles.
- **"Aplica", "sincroniza", "repara", "publica" o "despliega"** → detenerse antes de ejecutar nada remoto, mostrar proyecto vinculado, entorno afectado, comando exacto, cambios, riesgo, respaldo/recuperación y dry-run si existe, y solicitar autorización explícita. Una autorización para analizar o crear archivos locales nunca autoriza cambios remotos.

## Recordatorios

- Seguir las reglas de `CLAUDE.md` (trabajar por etapas pequeñas, no eliminar archivos sin autorización, no publicar claves, confirmar el dominio de datos afectado).
- Nunca ejecutar `supabase db push`, `supabase db reset --linked`, `supabase migration repair`, SQL remoto de escritura, `git push` o despliegue en Vercel sin autorización explícita.
- Nunca mostrar claves, tokens ni datos personales reales de estudiantes.
- Una auditoría del esquema no equivale a autorización para corregirlo.
