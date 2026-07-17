---
name: validapp-qa
description: Usa este skill para control de calidad en ValidApp — pruebas unitarias, de integración y end-to-end, detección de errores y regresiones, accesibilidad, diseño responsive, integridad de progreso/puntajes/resultados, y validación antes de publicar. Debe delegar el trabajo al agente validapp-qa-reviewer.
context: fork
agent: validapp-qa-reviewer
---

# validapp-qa

Este skill delega tareas de control de calidad y pruebas de ValidApp al agente `validapp-qa-reviewer`, que define el flujo de trabajo obligatorio, la matriz mínima de pruebas, la clasificación de severidad y el formato de informe completos.

Instrucción del usuario: $ARGUMENTS

## Procedimiento

1. Pasar la instrucción ($ARGUMENTS) al agente `validapp-qa-reviewer` para que ejecute su flujo de trabajo obligatorio (lectura de `CLAUDE.md`, `git status`, `package.json` y scripts, configuración de lint/TypeScript/pruebas, archivos modificados recientemente).
2. Clasificar la instrucción según los verbos que use (ver abajo) antes de actuar.
3. Si la instrucción requiere mejoras de diseño, migraciones/RLS, estructura curricular o lógica evaluativa, no ejecutarla: indicarlo y recomendar `/validapp-ui`, `/validapp-db`, `/validapp-content` o `/validapp-assessments` según corresponda.
4. Devolver al contexto principal un informe estructurado siguiendo el formato de respuesta del agente.

## Clasificación de la orden

- **"Analiza", "revisa" o "audita"** → inspeccionar código y configuración. No modificar archivos. Puede ejecutar verificaciones locales no destructivas. Entregar hallazgos y recomendaciones.
- **"Prueba", "verifica" o "comprueba"** → ejecutar las pruebas existentes y, si corresponde, iniciar la aplicación local. No modificar código. Documentar errores, comandos y resultados. No instalar dependencias sin autorización.
- **"Crea pruebas" o "implementa pruebas"** → crear o modificar archivos locales de pruebas. No cambia lógica de producción salvo solicitud expresa. Comprobar que la prueba falle antes de corregir (cuando sea posible) y pase después.
- **"Corrige" o "implementa la solución"** → modificar código local con el cambio mínimo necesario, preservando cambios existentes del usuario, y volver a ejecutar las pruebas relacionadas. No modifica Supabase remoto ni despliega.
- **"Prueba producción", "publica" o "despliega"** → detenerse antes de cualquier acción sobre staging/producción, mostrar entorno, URL/proyecto, pruebas propuestas, posibles datos creados, efectos en usuarios, credenciales requeridas y procedimiento de limpieza, y solicitar autorización explícita. Nunca desplegar cambios.

## Recordatorios

- Seguir las reglas de `CLAUDE.md` (trabajar por etapas pequeñas, no eliminar archivos sin autorización, mobile-first).
- Nunca usar datos reales de estudiantes ni credenciales reales en pruebas o capturas.
- Nunca ejecutar `supabase db push`, `supabase db reset --linked`, `migration repair`, modificar RLS, hacer `git push` o desplegar en Vercel.
- Nunca ocultar pruebas fallidas ni declarar que todo funciona sin haber podido verificarlo.
- Una revisión o auditoría de calidad no equivale a autorización para publicar o desplegar.
