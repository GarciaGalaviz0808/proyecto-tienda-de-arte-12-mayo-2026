# 📁 .agents/ — Eli's Art Supplies

Carpeta de configuración del entorno agéntico (Antigravity) para el proyecto **Eli's Art Supplies**.

## Archivos

| Archivo | Propósito |
|---|---|
| `system_prompt.md` | Rol, comportamiento y reglas estrictas del agente |
| `project_context.md` | Arquitectura, stack, pantallas y routing |
| `database_mapping.md` | Diseño Firestore, colecciones, índices y reglas |
| `ui_theme_rules.md` | Paleta, tipografía, componentes y accesibilidad |
| `agent_tasks.md` | Roadmap por fases con checklist |
| `memory/initial_notes.md` | Decisiones de arquitectura y recordatorios críticos |
| `antigravity_config.json` | Configuración del agente Antigravity |

## Stack

- **Flutter + Dart** — Frontend móvil
- **Firebase** — Firestore + Auth (email/contraseña)
- **Provider** — Gestión de estado
- **go_router** — Navegación declarativa
- **Sin telemetría** — Cero analytics, crashlytics o rastreo

## Roles de usuario

`customer` · `admin` · `superadmin`

## Notas

- No hardcodear claves de Firebase en el código fuente.
- Todo acceso a datos debe validarse contra `users.role` y `admin_permissions`.
- El build objetivo es APK en modo desarrollador para dispositivo físico.
