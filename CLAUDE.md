# ValidApp

ValidApp es una plataforma educativa chilena para preparar exámenes de validación de estudios (exámenes libres, currículum MINEDUC). Combina gamificación, adaptación por edad/nivel y contenido alineado al currículum oficial.

## Público principal

- Adultos que desean terminar sus estudios básicos o medios.
- Padres de menores que rendirán exámenes libres.
- Instituciones educativas que quieran validar estudios de sus alumnos.

## Arquitectura del sistema

La aplicación se organiza en 4 capas. Claude Code debe respetar esta separación al proponer o modificar código: no mezclar lógica de datos dentro de componentes de UI, ni credenciales de despliegue dentro del código de la app.

```
1. Personas        Estudiante · Administrador
                         │
2. Aplicación       ValidApp (Next.js, diseño responsive)
                         │
3. Servicios y datos     Supabase (Auth · DB · Storage)
                         ├── Autenticación y usuarios
                         ├── Contenido y preguntas
                         └── Resultados y progreso
                         │
4. Desarrollo y despliegue
     Claude Code + VS Code → GitHub de ValidApp → Vercel (publica)
     (con control de versiones en loop hacia el repo)
```

### Roles y permisos

- **Estudiante**: se registra, rinde diagnóstico, avanza por su ruta educativa, completa lecciones, revisa su propio progreso. No accede a datos de otros estudiantes ni a panel administrativo.
- **Administrador**: gestiona contenido y preguntas, visualiza resultados y progreso agregado, administra cuentas de estudiantes. Cualquier función nueva de administrador debe considerar qué datos puede ver y qué acciones puede ejecutar — no asumir acceso total por defecto.

## Objetivo del MVP

Permitir que un estudiante se registre, realice un diagnóstico, acceda a una ruta educativa, complete lecciones y revise su progreso. El administrador debe poder cargar/editar contenido y ver resultados de los estudiantes.

## Tecnología por capa

| Capa | Tecnología |
|---|---|
| Aplicación | Next.js, TypeScript, Tailwind CSS, shadcn/ui |
| Datos y servicios | Supabase (Auth, Postgres, Storage) |
| Despliegue | GitHub (repo de ValidApp) → Vercel |
| Desarrollo asistido | Claude Code + VS Code |

## Modelo de datos en Supabase (alto nivel)

Al diseñar tablas o queries, ubicar cada elemento dentro de uno de estos tres dominios y evitar mezclarlos en una sola tabla monolítica:

- **Autenticación y usuarios**: perfiles, roles (estudiante/administrador), datos de cuenta.
- **Contenido y preguntas**: lecciones, rutas educativas, banco de preguntas por nivel/asignatura.
- **Resultados y progreso**: diagnósticos rendidos, avance por lección, historial de puntajes.

## Flujo de desarrollo y despliegue

1. Todo el código se trabaja localmente con Claude Code + VS Code.
2. Los cambios se suben al repositorio de GitHub de ValidApp (no a un repo personal).
3. Vercel despliega automáticamente desde ese repo.
4. El control de versiones debe quedar siempre en el repo de GitHub — no dejar cambios sin commitear como única copia.

## Cuentas y accesos (regla importante)

Las cuentas y accesos principales — GitHub, Supabase, Vercel, dominio — deben pertenecer a ValidApp como organización/proyecto, no a una cuenta personal individual. Si Claude Code sugiere crear una cuenta o configurar un acceso nuevo, debe preguntar primero si corresponde crearlo bajo la organización de ValidApp.

## Estilo visual

Cercano, dinámico, motivador y gamificado. Debe sentirse profesional y fácil de usar. Usar lenguaje simple y español de Chile.

## Reglas de trabajo

- Trabajar por etapas pequeñas.
- Explicar los cambios antes de realizarlos.
- No eliminar archivos sin autorización.
- No publicar claves ni contraseñas, ni dejarlas escritas en el código o en este archivo.
- Mantener la aplicación adaptable a celular (mobile-first).
- Ejecutar pruebas después de cada función.
- Antes de tocar autenticación, contenido o resultados, confirmar en qué dominio de datos cae el cambio (ver "Modelo de datos en Supabase").

## Diseño UX/UI de ValidApp

- Existe el agente `validapp-ui-designer` (`.claude/agents/validapp-ui-designer.md`), especializado en UX/UI educativo, gamificación, frontend, accesibilidad y consistencia visual.
- Existe el skill `/validapp-ui` (`.claude/skills/validapp-ui/SKILL.md`) que delega en ese agente.
- Las tareas de diseño visual o de interfaz deben usar ese agente/skill en lugar de modificarse de forma ad hoc.
- La identidad visual debe ser original: se inspira en la claridad y gamificación de apps como Duolingo, pero no debe copiar su interfaz, personajes ni marca.
- Antes de publicar cualquier cambio visual (git push, despliegue en Vercel) se necesita autorización explícita del usuario.
