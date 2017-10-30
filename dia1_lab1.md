# Dia 1 - Laboratorio 1

El objetivo de este laboratorio es crear un playbook que dadas 3 máquinas haga las siguientes tareas:

1. Instalar el servidor http nginx
2. Configurar el servidor http nginx
3. Active y arranque el servidor http nginx
4. Despliegue una página de bienvenida

Una vez hecho esto, segregaremos el playbook en roles para facilitar su reuso, y 
adaptaremos la página de bienvenida para que varie en función del host.

## Arrancar el laboratiorio

```bash
ansible-playbook crear-lab1s1.yml
```

Tras unos segundos este playbook habrá creado 3 máquinas Centos 7, podéis ver sus IP's en el 
fichero ```inventories/dia1lab1.yml```

Para acceder a ellas podréis hacerlo mediante el usuario "centos", con la clave pública que
se os ha dado justo con el fichero aws_vault.yml

Recomendamos dejar la clave pública en el directorio $HOME del usuario que vayáis a usar 
en la VM de laboratorio que se usa para control. De esta forma los comandos de la documentación
se ajustarán al entorno.

Ejemplo de comando para acceder a una de las máquinas de lab:

```ssh -i $HOME/curso-itnow.pem centos@a.b.c.d```

# Ejercicio 1

Ficheros resultantes que debe haber en la raíz del repositorio:

- d1l1_configurar_nginx.yml
- files/index.html
- files/nginx_vhost.cfg

Empecemos:

Primero adaptaremos el inventario, actualmente sólo tiene las IP's de los hosts que 
queremos configurar. Segmentaremos por grupo para que no tengamos que usar el grupo "all",
que incluye a localhost:

```
[www]
34.240.57.148
34.251.5.188
34.241.50.217
```

De esta forma nuestros 3 hosts están en el grupo www.

Para facilitarnos el trabajo podemos definir una serie de variables, 
sabiendo que el usuario que vamos a utilizar se llama centos

```
[www]
34.240.57.148
34.251.5.188
34.241.50.217

[www:vars]
ansible_user=centos
ansible_private_key_file=/root/curso-itnow.pem
ansible_host_key_checking=false
```

**nota:** para esto nos apoyamos en lo que se llama "Behavioral Inventory Parameters" (ver http://docs.ansible.com/ansible/latest/intro_inventory.html#list-of-behavioral-inventory-parameters)

Seguimos con la escritura del playbook, es un fichero yaml en el que habrá una play 
que instalará y configurará nginx y otra que desplegará la plantilla.

Empezaría de la siguiente forma:

```yaml
- name: configurar nginx
  hosts: www
  tasks:
    - name: instalar paquete nginx000
```

Ahora necesitamos un módulo que instale paquetes, en nuestro caso al tratar con un sistema centos
usaremos el módulo **yum**

```yaml
- name: configurar nginx
  hosts: www
  tasks:
    - name: instalar paquete nginx
      yum:
        name: "nginx"
        state: present
```

Si ejecutamos el playbook que acabamos de crear mediante el comando:

```bash
ansible-playbook -i inventories/dia1lab1.yml d1l1_configurar_nginx.yml
```

Nos fallará con un error que indica que la tarea no se puede completar porque no somos root.

**¿Por qué está pasando esto?**

La conexión se establece con el usuario "centos", que no tiene permisos para hacer un yum install.
Pero si puede hacer sudo.

Esto se consigue mediante el parámetro "become: True"

Se puede poner a nivel de play o de tarea.  **¿Dónde pensáis que es mejor hacerlo?**

```yaml
- name: configurar nginx
  hosts: www
  become: True
  tasks:
    - name: instalar paquete nginx
      yum:
        name: "nginx"
        state: present
```

Si ejecutamos de nuevo el playbook veremos que no falla y que saca el siguiente output:

```
PLAY [configurar nginx] ******************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************
ok: [34.240.57.148]
ok: [34.251.5.188]
ok: [34.241.50.217]

TASK [instalar paquete nginx] ************************************************************************************************************************
changed: [34.240.57.148]
changed: [34.241.50.217]
changed: [34.251.5.188]

PLAY RECAP *******************************************************************************************************************************************
34.240.57.148              : ok=2    changed=1    unreachable=0    failed=0   
34.241.50.217              : ok=2    changed=1    unreachable=0    failed=0   
34.251.5.188               : ok=2    changed=1    unreachable=0    failed=0
```

Observad que hay una tarea que nadie ha definido -> Gathering Facts

### desvío temporal -> los facts

Es un buen momento para introducir el concepto vars vs facts:
- vars: variables definidas por el usuario/programador
- facts: variables recogidas por ansible, empiezan por ansible_

Si queréis recoger los facts de las 3 máquinas del lab para ver que hay, podéis ejecutar:

```bash
ansible all -i inventories/dia1lab1.yml -m setup
```

### seguimos con el playbook

El resultado de la tarea "instalar paquete nginx" es "changed" para los 3 nodos. Lo que indica
que nginx no estaba instalado en ningún nodo.
Si lo volvemos a ejecutar el estado será "ok", que indica que no han habido cambios porque
nginx ya está instalado (idempotencia).

Ahora nos falta configurar nginx y arrancarlo.

Para facilitar el trabajo existen los ficheros:
- files/nginx.conf
- files/vhost_default.conf

Para pasar estos ficheros del host de control a los hosts que queremos configurar, usaremos el
módulo copy (http://docs.ansible.com/ansible/latest/copy_module.html).

Opcional: **¿Porqué no usamos el módulo template?**

```yaml
- name: configurar nginx
  hosts: www
  become: True
  tasks:
    - name: instalar paquete nginx
      yum:
        name: "nginx"
        state: present
    - name: configuración base nginx
      copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
    - name: configuración vhost nginx
      copy:
        src: files/vhost_default.conf
        dest: /etc/nginx/conf.d/vhost_default.conf
```

Si ejecutamos el playbook veremos que las nuevas tareas generan dos stados en changed (los dos ficheros)

Ahora ya tenemos nginx configurado. Podemos proceder a arrancarlo. Esto lo haremos mediante el 
módulo service:

```yaml
- name: configurar nginx
  hosts: www
  become: True
  tasks:
    - name: instalar paquete nginx
      yum:
        name: "nginx"
        state: present
    - name: configuración base nginx
      copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
    - name: configuración vhost nginx
      copy:
        src: files/vhost_default.conf
        dest: /etc/nginx/conf.d/vhost_default.conf
    - name: arrancar nginx
      service:
        name: nginx
        state: started
        enabled: yes
```

La línea "enabled: yes" nos asegura que cuando reiniciemos el servidor nginx arrancará.

Si volvemos a aplicar el playbook, veremos que la tarea de arrancar nginx acaba en changed,
ahora ya podremos acceder por web a cualquier ip y nos devolverá la página por defecto.

Antes de pasar a la parte de desplegar la  página web de ejemplo, tomemos una cosa en cuenta:
- Si más adelante queremos actualizar la configuración de nginx, ¿que deberá pasar con nginx?
- ¿Que elemento de ansible nos permite hacer eso?
 
Vamos a implementarlo.

```yaml
- name: configurar nginx
  hosts: www
  become: True
  tasks:
    - name: instalar paquete nginx
      yum:
        name: "nginx"
        state: present
    - name: configuración base nginx
      copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
      notify: reload nginx
    - name: configuración vhost nginx
      copy:
        src: files/vhost_default.conf
        dest: /etc/nginx/conf.d/vhost_default.conf
      notify: reload nginx
    - name: arrancar nginx
      service:
        name: nginx
        state: started
        enabled: yes
  handlers:
    - name: reload nginx
      service:
        name: nginx
        state: reloaded
```

Si ejecutamos el playbook, no ocurrirá nada. Pero introduzcamos un cambio en alguno de los ficheros
de configuración (un comentario) y despleguemos de nuevo.

Veremos lo siguiente:

```bash
TASK [configuración base nginx] **********************************************************************************************************************
changed: [34.251.5.188]
changed: [34.241.50.217]
changed: [34.240.57.148]
```

```bash
RUNNING HANDLER [reload nginx] ***********************************************************************************************************************
changed: [34.251.5.188]
changed: [34.241.50.217]
changed: [34.240.57.148]
```

Resumiendo, el cambiar la config base de nginx (fichero files/nginx.conf), ha provocado que en 
la nueva ejecución del playbook se haya disparado el handler de reload del nginx.

Pasamos a la pare final del ejercicio: desplegar la página de bienvenida. 
La haremos en una play separada para separar lo que es la configuración del servicio del código
de la aplicación.

Usaremos el módulo copy para copiarla, y asignarle los permisos que espera nginx.

```yaml
- name: configurar nginx
  hosts: www
  become: True
  tasks:
    - name: instalar paquete nginx
      yum:
        name: "nginx"
        state: present
    - name: configuración base nginx
      copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
      notify: reload nginx
    - name: configuración vhost nginx
      copy:
        src: files/vhost_default.conf
        dest: /etc/nginx/conf.d/vhost_default.conf
      notify: reload nginx
    - name: arrancar nginx
      service:
        name: nginx
        state: started
        enabled: yes
  handlers:
    - name: reload nginx
      service:
        name: nginx
        state: reloaded
- name: desplegar página de bienvenida
  hosts: www
  become: True
  tasks:
    - name: copiar página de bienvenida
      copy:
        src: files/index.html
        dest: /usr/share/nginx/html/index.html
```

# Ejercicio 2

Vamos a ver un poco el funcionamiento de las plantillas. 

La página de inicio va a variar en función del hostname donde se ejecute.

Para ello lo primero que haremos será crear el directorio templates

```bash
mkdir templates
```

Y copiaremos la página de inicio estática dentro, pero con extensión ".j2"

```bash
cp files/index.html templates/index.html.j2
```

Aprovecharemos los facts que recoge ansible para hacer nuestra página dinámica, dejándo el fichero con 
el siguiente contenido:

```html
<html>
<head><title>P&aacute;gina aburrida de inicio</title></head>
<body>
&Eacute;sto es una p&aacute;gina aburrida de inicio<br />
Y se ejecuta en {{ ansible_nodename }}
</body>
</html>
```

Y cambiaremos el módulo de despliegue de "copy" a "template", adaptando los parámetros también:

```yaml
- name: desplegar página de bienvenida
  hosts: www
  become: True
  tasks:
    - name: copiar página de bienvenida
      template:
        src: templates/index.html.j2
        dest: /usr/share/nginx/html/index.html
```

Si ejecutamos de nuevo el playbook veremos que despliega la página y que es diferente en los tres nodos.

# Ejercicio 3

Vamos a separar las tareas de la play de nginx en un rol, para hacer que el mantenimiento del playbook sea
más simple.

1. Creamos la carpeta roles/nginx en el host de control

```bash
mkdir -p roles/nginx
```

2. Mirando los componentes que usa el rol nginx vemos que son: files, tasks, handlers por lo que creamos lo siguiente en el host de control

```bash
mkdir -p roles/nginx/tasks
mkdir -p roles/nginx/handlers
mkdir -p roles/nginx/files
```

3. Copiamos los ficheros de config de nginx dentro del rol

```bash
cp files/nginx.conf roles/nginx/files
cp files/vhost_default.conf roles/nginx/files
```
4. Creamos el fichero de handlers "roles/nginx/handlers/main.yml" y ponemos el handler dentro

```yaml
- name: reload nginx
  service:
    name: nginx
    state: reloaded
```

5. Creamos el fichero de tareas "roles/nginx/tasks/main.yml" y traspasamos/adaptamos las tareas

```yaml
- name: instalar paquete nginx
  yum:
    name: "nginx"
    state: present
- name: configuración base nginx
  copy:
    src: files/nginx.conf
    dest: /etc/nginx/nginx.conf
  notify: reload nginx
- name: configuración vhost nginx
  copy:
    src: files/vhost_default.conf
    dest: /etc/nginx/conf.d/vhost_default.conf
  notify: reload nginx
- name: arrancar nginx
  service:
    name: nginx
    state: started
    enabled: yes
```

Ahora ya tendríamos preparado el rol, por lo que modificaremos el playbook:

```yaml
- name: configurar nginx
  hosts: www
  become: True
  roles:
    - nginx
    
- name: desplegar página de bienvenida
  hosts: www
  become: True
  tasks:
    - name: copiar página de bienvenida
      template:
        src: templates/index.html.j2
        dest: /usr/share/nginx/html/index.html
```

Hacemos limpieza de ficheros
```bash
rm -f files/nginx.conf
rm -f files/vhost_default.conf
```

Si ejecutamos el playbook, no debería cambiar nada, sólo hemos refactorizado el código.

# Fin del laboratorio

Ha acabado el laboratorio, tras él deberíamos haber asimilado los conceptos de:
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
ansible-playbook borrar-labs1s1.yml
```

