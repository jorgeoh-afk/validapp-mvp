---
name: validapp-ui
description: Usa este skill cuando se solicite diseñar, rediseñar, mejorar, revisar o implementar una pantalla, componente, flujo educativo o sistema visual de ValidApp. Debe delegar el trabajo al agente validapp-ui-designer.
context: fork
agent: validapp-ui-designer
---

# validapp-ui

Este skill delega tareas de diseño UX/UI y frontend de ValidApp al agente `validapp-ui-designer`.

Instrucción del usuario: $ARGUMENTS

## Procedimiento

1. Analizar la solicitud recibida ($ARGUMENTS).
2. Localizar las páginas y componentes involucrados (`app/`, `components/`, `app/globals.css`).
3. Revisar el funcionamiento existente antes de proponer cambios.
4. Presentar un breve diagnóstico (qué existe hoy, qué se conserva).
5. Proponer los cambios visuales.
6. Implementar los cambios solo si la instrucción lo solicita explícitamente.
7. Ejecutar lint, pruebas y build (`npm run lint`, `npm run build`, pruebas disponibles).
8. Revisar diseño responsive (mobile-first) y accesibilidad básica (contraste, foco, texto alternativo).
9. Informar los archivos modificados y las pruebas manuales realizadas.

## Clasificación de la orden

Antes de actuar, clasifica la instrucción recibida:

- **"Analiza" o "revisa"** → solo inspeccionar y proponer, no modificar archivos.
- **"Diseña"** → crear propuesta y maqueta (puede incluir código de ejemplo), sin necesariamente reemplazar lo existente en producción.
- **"Implementa", "mejora" o "corrige"** → modificar los archivos correspondientes, dentro del alcance pedido.
- **"Publica"** → detenerse de inmediato y solicitar autorización explícita antes de cualquier despliegue (git push, Vercel). Este skill y el agente nunca publican por sí mismos.

## Recordatorios

- No copiar literalmente la interfaz de Duolingo ni de otra plataforma; inspirarse en su claridad y gamificación, pero con identidad propia de ValidApp.
- Seguir las reglas de CLAUDE.md (trabajar por etapas pequeñas, no eliminar archivos sin autorización, mobile-first, no publicar claves).
- Reutilizar componentes existentes en `components/ui/` antes de crear nuevos.
