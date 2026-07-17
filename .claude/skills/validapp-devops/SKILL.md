---
name: validapp-devops
description: Usa este skill para infraestructura y despliegue de ValidApp — Git/GitHub, GitHub Actions, Vercel, Supabase CLI y vinculación de proyectos, variables de entorno, entornos (desarrollo/staging/producción), dominios (validapp.cl), build de Next.js, coordinación de migraciones y despliegues, respaldos y accesos del equipo. Debe delegar el trabajo al agente validapp-devops-engineer.
context: fork
agent: validapp-devops-engineer
---

# validapp-devops

Este skill delega tareas de infraestructura, Git/GitHub, Vercel, Supabase CLI y despliegue de ValidApp al agente `validapp-devops-engineer`, que define el flujo de trabajo obligatorio, los controles por entorno, el orden de despliegue y el formato de informe completos.

Instrucción del usuario: $ARGUMENTS

El comportamiento predeterminado de esta skill es de **solo lectura**: ante cualquier ambigüedad sobre si una instrucción pide auditar o actuar sobre GitHub/Vercel/Supabase/DNS, tratarla como auditoría de solo lectura hasta que el usuario lo aclare. **Ninguna instrucción de esta skill autoriza un despliegue automático** — commit, push, PR, despliegue, transferencia de cuenta o cambio de dominio siempre requieren autorización explícita del usuario, mostrada antes de ejecutar cualquier acción externa.

## Procedimiento

1. Pasar la instrucción ($ARGUMENTS) al agente `validapp-devops-engineer` para que ejecute su flujo de trabajo obligatorio (lectura de `CLAUDE.md`, `git status`, rama actual, remotos sin mostrar credenciales, `package.json`, configuración de Vercel/Supabase, entorno y cuentas vinculadas).
2. Clasificar la instrucción según los verbos que use (ver abajo) antes de actuar.
3. Si la instrucción requiere migraciones/RLS, seguridad, pruebas de QA, interfaz, currículo o lógica evaluativa, no ejecutarla directamente: indicarlo y recomendar `/validapp-db`, `/validapp-security`, `/validapp-qa`, `/validapp-ui`, `/validapp-content` o `/validapp-assessments` según corresponda.
4. Devolver al contexto principal un informe estructurado siguiendo el formato de respuesta del agente (auditoría o despliegue autorizado, según corresponda), sin mostrar valores de variables secretas.

## Clasificación de la orden

- **"Analiza", "revisa", "audita" o "comprueba"** → solamente lectura. No modificar archivos ni servicios externos. Puede ejecutar comandos locales no destructivos. Entregar hallazgos, riesgos y recomendaciones.
- **"Diseña", "planifica" o "propón"** → preparar un procedimiento con comandos y orden de ejecución. No ejecutar cambios locales ni externos.
- **"Prepara", "configura localmente" o "implementa localmente"** → modificar archivos locales de configuración, workflows de CI o documentación técnica. No hace commit, push, PR ni deploy automáticamente. Ejecuta lint, pruebas y build correspondientes.
- **"Commit"** → mostrar `git status` y los archivos incluidos, excluir archivos ajenos al alcance, proponer el mensaje, y pedir autorización explícita antes de crearlo.
- **"Push", "abre un PR", "publica" o "despliega"** → mostrar repositorio, rama local/remota, commit, entorno afectado, resultado de lint/pruebas/build, variables necesarias (solo nombres), riesgo y rollback, y el comando exacto — luego solicitar autorización explícita.
- **"Transfiere", "cambia la cuenta", "modifica dominio" o "cambia accesos"** → detenerse y presentar cuenta actual/destino, activos afectados, usuarios impactados, riesgo de interrupción, respaldo y recuperación. Nunca asumir autorización para transferir propiedad.

## Recordatorios

- Seguir las reglas de `CLAUDE.md` (cuentas y accesos deben pertenecer a la organización ValidApp, no publicar claves ni contraseñas, publicar solo con autorización explícita).
- Nunca imprimir valores de variables secretas — solo nombres, ubicación y riesgo.
- Nunca `git push --force`, `git reset --hard`, reescribir historia compartida, ni borrar ramas/repositorios sin autorización.
- Nunca ejecutar `supabase db reset --linked`, `db push` o `migration repair` sin autorización explícita; no sustituye a `/validapp-db`.
- Nunca desplegar en producción, transferir cuentas o cambiar dominios sin autorización explícita mostrada previamente.
- Una auditoría de infraestructura no equivale a autorización para desplegar, transferir o modificar accesos.
