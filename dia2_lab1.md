# Dia 2 - Laboratorio 1

El objetivo de este laboratorio es que todos los alumnos tengan una cuenta de github 
y acaben interactuando con ella.

## Ejercicio 1 - Alta en github

https://github.com/join?source=login

## Ejercicio 2 - Inicializar el primer repositorio

1. En github, crear un repositorio llamado "test"
2. En el host de control, ir al directorio $HOME y crear un repo vacío

```
cd $HOME
mkdir repotest
cd repotest
git init .
```

Observar que se ha creado una carpeta .git, mirad el contenido

3. Crear el fichero README.md con el siguiente contenido

```markdown
# REPOSITORIO DE PRUEBA

Esto es un repositorio de prueba, a ver como funciona
```

4. Ejecutar el comando ```git status```

Veremos que indica que el fichero "README.md" es nuevo, y que no está añadido

5. Añadir el fichero al staging local mediante el comando ```git add README.md```

6. Repetir el comando ```git status```, veremos la diferencia con el comando anterior

7. Hacer commit con ```git commit -m "commit inicial"```

Ahora en el repositorio del host de control hay un punto inicial que contiene nuestro fichero README.md, pero no está en github



## Ejercicio 3 - Enviar al repositorio remoto

1. Añadir el origen remoto (tomar la url que indica github)

```bash
git remote add origin https://....
```

2. Enviar el contenido local al remoto

```bash
git push -u origin master
```

3. Revisar en Github que vemos el fichero README.md


## Ejercicio 4 - Dar acceso a gente del equipo al repositorio

Formaremos grupos de 3-4 personas (dependiendo del tamaño del aula) y se escogerá uno de los repositorios
como repositorio del equipo. Daremos permiso a todos los miembros del equipo mediante los settings
del repositorio, en la parte de Add Collaborators.

Los colaboradores harán clone del repositorio en su host de control:

(hay que tomar la URL de github)

```bash
cd $HOME
git clone https://github.com... test-equipo
```

Ahora en el directorio test-equipo todos verán el repositorio común.

## Ejercicio 5 - Cada miembro crea un cambio y lo envía a github

En este ejercicio cada miembro del equipo hará un cambio, creará un fichero nuevo... en el repositorio, 
y lo enviará al github.

Deberían ocurrir situaciones como:
- Conflictos
- Necesidad de pull antes de hacer push


# Fin del laboratorio

En este laboratorio se habrán obtenido los siguientes conocimientos:
- Inicialización de un repositorio git local
- Colaboración online mediante github
- Conflictos
- Pull antes de Push

