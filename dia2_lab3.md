# Dia 2 - Laboratorio 3

El objetivo de este laboratorio es aprender el funcionamiento de los tags en ansible y aplicar 
las guidelines del equipo que se han definido en el laboratorio 2.

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

## Ejercicio 1 - Preparar el inventario

- Dos de los 3 hosts creados serán del grupo www, y 1 de ellos del grupo bbdd

```
[www]
34.240.57.148
34.251.5.188
[bbdd]
34.241.50.217

[all:vars]
ansible_user=centos
ansible_private_key_file=/root/curso-itnow.pem
ansible_host_key_checking=false
```

## Ejercicio 2 - Preparar tags

Aplicaremos los tags a nivel de las plays de los roles.

Es mucho más sencillo, y propaga el tag a las tareas.
 
El playbook lo llamaremos "d2l3_configurar_env.yml", simplemente tendremos que añadir tags en cada play.

Llamaremos a los tags "www" y "bbdd"

```yaml
- name: configurar nginx
  hosts: www
  become: True
  roles:
    - nginx
  tags: www

- name: desplegar página de bienvenida
  hosts: www
  become: True
  tasks:
    - name: copiar página de bienvenida
      template:
        src: templates/index.html.j2
        dest: /usr/share/nginx/html/index.html
  tags: www

- name: instalar mysql
  hosts: bbdd
  become: True
  roles:
    - mysql
  tags: bbdd
```

## Ejercicio 3 - Probar ejecuciones

Los comandos para ejecutar los diferentes plays en función a los tags son:

```bash
ansible-playbook -i inventories/dia2lab3.yml d2l3_configurar_env.yml --tags www
```

```bash
ansible-playbook -i inventories/dia2lab3.yml d2l3_configurar_env.yml --tags bbdd
```

¿Que combinaciones deberían hacerse para validar que el playbook funciona en cualquier caso?

¿Que implicaciones tiene? ¿Que ocurre con un playbook que tenga 4 tags diferentes?


# Fin del laboratorio

En este laboratorio se habrán adquirido los siguientes conocimientos:
- Aplicación de tags en playbooks
- Ejecución selectiva de plays
- Problemas del exceso de tagging 

Procederemos a la destrucción del laboratorio:

```bash
ansible-playbook borrar-labs3s2.yml
```