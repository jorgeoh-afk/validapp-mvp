---
name: validapp-security
description: Usa este skill para seguridad de ValidApp — Supabase Auth, sesiones, roles de estudiante/administrador, Row Level Security y políticas, funciones SECURITY DEFINER, protección de secretos y variables de entorno, validación de entradas, y datos personales/educativos de menores. Debe delegar el trabajo al agente validapp-security-auditor.
context: fork
agent: validapp-security-auditor
---

# validapp-security

Este skill delega tareas de seguridad y privacidad de ValidApp al agente `validapp-security-auditor`, que define el flujo de trabajo obligatorio, los controles mínimos, las acciones prohibidas y el formato de informe completos.

Instrucción del usuario: $ARGUMENTS

El comportamiento predeterminado de esta skill es de **solo lectura**: ante cualquier ambigüedad sobre si una instrucción pide auditar o modificar, tratarla como auditoría de solo lectura hasta que el usuario lo aclare.

## Procedimiento

1. Pasar la instrucción ($ARGUMENTS) al agente `validapp-security-auditor` para que ejecute su flujo de trabajo obligatorio (lectura de `CLAUDE.md`, `git status`, `package.json`, clientes Supabase de navegador/servidor, middleware y rutas protegidas, migraciones y políticas sin modificarlas).
2. Clasificar la instrucción según los verbos que use (ver abajo) antes de actuar.
3. Si la instrucción requiere migraciones/RLS remoto, mejoras de interfaz, pruebas generales de QA, estructura curricular o lógica evaluativa, no ejecutarla: indicarlo y recomendar `/validapp-db`, `/validapp-ui`, `/validapp-qa`, `/validapp-content` o `/validapp-assessments` según corresponda.
4. Devolver al contexto principal un informe estructurado siguiendo el formato de respuesta del agente, sin mostrar secretos ni datos reales.

## Clasificación de la orden

- **"Analiza", "revisa" o "audita"** → exclusivamente lectura. No modificar archivos ni Supabase. Puede ejecutar verificaciones locales no destructivas. Entregar riesgos, evidencia y recomendaciones.
- **"Diseña" o "propón"** → diseñar políticas, controles y correcciones. No crear migraciones ni ejecutar SQL. Indicar cuándo la implementación corresponde a `/validapp-db`.
- **"Implementa" o "corrige localmente"** → modificar código local de autenticación, validación o protección, y crear pruebas locales. No aplica cambios remotos. Si requiere modificar RLS, entrega el requerimiento a `/validapp-db`. Ejecuta lint, pruebas y build relacionados.
- **"Aplica", "habilita", "deshabilita", "publica" o "despliega"** → detenerse y mostrar proyecto/entorno afectados, control de seguridad que cambiaría, tablas o usuarios afectados, riesgo de pérdida o exposición, comando o SQL exacto, resultado esperado, método de reversión y pruebas realizadas, y solicitar autorización explícita.

## Recordatorios

- Seguir las reglas de `CLAUDE.md` (no publicar claves ni contraseñas, confirmar el dominio de datos afectado).
- **Nunca** desactivar RLS —tampoco como solución rápida en producción— ni proponerlo como corrección válida sin análisis.
- Nunca mostrar tokens, claves, contraseñas, `service_role`, ni datos personales reales de estudiantes.
- Nunca ejecutar `supabase db push`, `supabase db reset --linked`, `migration repair`, SQL remoto de escritura, `git push` o desplegar en Vercel sin autorización explícita.
- Una auditoría de seguridad no equivale a autorización para aplicar correcciones ni cambios remotos.
