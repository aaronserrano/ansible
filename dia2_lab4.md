# Dia 2 - Laboratorio 4

El objetivo de este laboratorio es aprender como crear un repositorio de organización, y como 
integrar playbooks y roles existentes en él.

Se puede reciclar código de otros laboratorios anteriores.


## Arrancar el laboratiorio

```bash
ansible-playbook crear-lab3s2.yml
```

Tras unos segundos este playbook habrá creado 3 máquinas Centos 7, podéis ver sus IP's en el 
fichero ```inventories/dia2lab3.yml```

Para acceder a ellas podréis hacerlo mediante el usuario "centos", con la clave pública que
se os ha dado justo con el fichero aws_vault.yml

Recomendamos dejar la clave pública en el directorio $HOME del usuario que vayáis a usar 
en la VM de laboratorio que se usa para control. De esta forma los comandos de la documentación
se ajustarán al entorno.

Ejemplo de comando para acceder a una de las máquinas de lab:

```ssh -i $HOME/curso-itnow.pem centos@a.b.c.d```

## Ejercicio 1 - Crear el repositorio de organización

Crear una estructura de repositorio organizativo como la que hemos visto durante el curso, en la $HOME 
del usuario del host de control.

Como referencia:

```
ansible/
├── env_vars
├── module_utils
├── filter_plugins
├── inventories
│   ├── prod
│   └── devel
├── roles
│   ├── role1
│   │   └── tasks
│   └── role2
│       ├── files
│       ├── handlers
│       └── tasks
└── library
```

## Ejercicio 2 - preparar los inventarios

- Crearemos dos inventarios, uno de producción y otro de desarrollo. 
- El de prod tendrá una máquina en www y otra en bbdd. 
- El de dev tendrá una misma máquina en www y en bbdd

```
[www]
34.240.57.148
[bbdd]
34.241.50.217

[all:vars]
ansible_user=centos
ansible_private_key_file=/root/curso-itnow.pem
ansible_host_key_checking=false
```

## Ejercicio 3 - establecer configuración inicial

Situaremos en la raíz del repositorio un fichero ```ansible.cfg``` con un mínimo de configuración
para el correcto funcionamiento de ansible:

```
[defaults]
host_key_checking = False
```

Este fichero permitirá a los playbooks que esténe en la raiz del repo organizativo trabajar de la forma 
 que queremos. Sin este fichero, ansible pediría la key cada vez que se accede a un host nuevo (por ejemplo)

## Ejercicio 4 - trasladar uno de los playbooks al repo organizativo

Ahora copiaremos uno de los playbooks que hemos hecho a nuestro repo organizativo, 
y trataremos de ejecutarlo contra nuestros inventarios de desarrollo y producción.



# Fin del laboratorio

En este laboratorio se habrán adquirido los siguientes conocimientos:
- Creación de un repositorio organizativo
- Configuración por defecto de ansible
- Dependencias de un playbook

Procederemos a la destrucción del laboratorio:

```bash
ansible-playbook borrar-labs3s2.yml
```