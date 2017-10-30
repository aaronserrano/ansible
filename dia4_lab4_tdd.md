# Dia 4 - Laboratorio 4 - TDD

## Que es el TDD

El flujo "clásico" de desarrollo es:
1. Escribir código
2. Escribir tests
3. Pasar tests sobre código

TDD (Test Driven Development) propone cambiar este flujo de código para que sea:

1. Crear un test
2. Ejecutar todos los tests y validar si el nuevo test falla
3. Escribir el código que soluciona el error del nuevo test
4. Ejecutar todos los tests
5. Refactorizar el código

Este modo de desarrollo obliga a mantener las unidades de desarrollo (entregables) suficientemente pequeños como para 
mantener la base de código de los tests. Además asegura que si los tests (unitarios y de integración) están 
suficientemente maduros, no se entrega código que pueda romper funcionalidades ya implementadas.

## AntiPatterns

1. Tests que dependen en un entorno manipulado por tests previos
2. Dependencias entre tests
3. Test de rendimiento (debe quedar fuera del TDD, aunque implique un refactor)
4. Tests lentos
5. Test de implementación (debe quedar fuera del TDD, aunque implique un refactor)

## Práctica de TDD

Implementaremos un rol que instale el servidor web Apache en una Centos 7. Lo configurará para que escuche en el 
puerto 80 y instalará una página por defecto que contenga el texto Hello World.

1. Crear la estructura del nuevo rol
1. Escribir los tests
2. Probar que los tests fallan
4. Escribir las tareas que harán que los tests se cumplan
