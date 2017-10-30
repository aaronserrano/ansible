# Dia 1 - Laboratorio 2

El objetivo de este laboratorio es crear un playbook que dadas 3 máquinas haga las siguientes tareas:

Dado un grupo www de 2 máquinas

1. Instalar el servidor http nginx
2. Configurar el servidor http nginx 
3. Active y arranque el servidor http nginx 
4. Despliegue una página de bienvenida

Dado un grupo mysql de 1 máquina

1. Instalar el servidor mysql
2. Configurar mysql 
3. Activar y arrancar el servidor mysql


Dejando segregados los roles para configurar mysql y nginx

## Arrancar el laboratiorio

```bash
ansible-playbook crear-lab2s1.yml
```

Tras unos segundos este playbook habrá creado 3 máquinas Centos 7, podéis ver sus IP's en el 
fichero ```inventories/dia1lab2.yml```

Para acceder a ellas podréis hacerlo mediante el usuario "centos", con la clave pública que
se os ha dado justo con el fichero aws_vault.yml

Recomendamos dejar la clave pública en el directorio $HOME del usuario que vayáis a usar 
en la VM de laboratorio que se usa para control. De esta forma los comandos de la documentación
se ajustarán al entorno.

Ejemplo de comando para acceder a una de las máquinas de lab:

```ssh -i $HOME/curso-itnow.pem centos@a.b.c.d```


## Desarrollo del laboratorio

Este laboratorio está pensado para consolidar los conocimientos del laboratorio 1.

Se podrá reutilizar código del laboratorio 1.

Los pasos, a modo de guía, serían:
1. Preparar el inventario
2. Configurar nginx y desplegar la página
3. Crear el rol de mysql
4. Aplicar el playbook
5. Validar el resultado

Se comprobará con el profesor el playbook resultante

## Fin del laboratorio

Ha acabado el laboratorio, tras él deberíamos haber consolidado los conceptos de:
- playbook
- play
- task
- handler
- role
- variable (var)
- fact
- template
- inventory

Procederemos a la destrucción del laboratorio:

```bash
ansible-playbook borrar-labs2s1.yml
```

