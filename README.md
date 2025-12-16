# Rick and Morty App

Una app en Flutter para explorar los personajes de Rick and Morty. Puedes buscar, ver detalles y guardar tus favoritos.

## Cómo correr el proyecto

Se necesita tener Flutter 3.9.2 o superior instalado.

```bash
# Instalar dependencias
flutter pub get

# Generar los modelos
dart run build_runner build --delete-conflicting-outputs

# Correr la app
flutter run
```

Para correr los tests:

```bash
flutter test
```

## Arquitectura

Se usa Clean Architecture para mantener el código organizado y fácil de testear. La idea es separar la app en capas:

# Organizacion de directorios

- **data/** - Todo lo relacionado con obtener datos (API, base de datos local)
- **domain/** - La lógica de negocio pura, sin depender de Flutter
- **presentation/** - La UI, los blocs y los widgets

```
- core/ # Elementos compartidos (red, errores, constantes)
- features/
    - characters/
        - data/ # API calls, modelos, repos
        - domain/ # Entidades, interfaces, use cases
        - presentation/ # Pantallas, blocs, widgets
```

## Librerías

- **flutter_bloc** - Para manejar el estado. Me gusta porque separa bien la lógica de la UI
- **dio** - Cliente HTTP. Tiene interceptores que facilitan el manejo de errores
- **hive** - Base de datos local para guardar los favoritos. Es rápida y no necesita setup nativo
- **get_it** - Inyección de dependencias simple
- **freezed** - Genera los modelos inmutables automáticamente
- **cached_network_image** - Para cachear las imágenes de los personajes

## Funciones de la app

- Lista de personajes con scroll infinito
- Buscador por nombre
- Pantalla de detalle con Hero Animation
- Guardar favoritos (se persisten localmente)

## Notas

-   El apk esta en el directiorio docs/
