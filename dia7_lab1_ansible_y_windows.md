# Ansibe y Windows

## Supporting an Alien

Ansible estaba pensado inicialmente para automatizar únicamente sistemas que fueran alcanzables vía SSH. A partir de ahí
dada la demanda de poder integrar Ansible con Windows se fueron integrando de formas diferentes, esto provocó varios
cambios:, en variables globales por ejemplo (ansible_ssh_host a ansible_host, por ejemplo)

Hay que tener en cuenta que el soporte de Ansible para Windows existe desde la versión 1.7 (en beta) y que se hizo 
público a partir de la versión 2.1 (Mayo 2016)

### Controlando máquinas windows

Las máquinas windows no disponen de SSH ni de Python de base. Es por ello que se administran via WinRM.

Ansible no soporta ser ejecutado desde windows, es por ello que se depende de tener un control host que ejecute 
GNU/Linux. Se puede usar Ansible desde la WSL.

Hay un poco de esperanza en tanto que Microsoft anuncio el posible soporte nativo de SSH en 2015... pero estamos a 
finales de 2017 y aún no ha llegado 
(https://blogs.msdn.microsoft.com/powershell/2015/06/03/looking-forward-microsoft-support-for-secure-shell-ssh/)

Las variables a tener en cuenta para tener conectividad hacia un host windows son:
- ansible_user
- ansible_password
- ansible_port
- ansible_winrm_scheme (http/https)

Todos los módulos de Ansible para Windows están escritos en PowerShell, es por ello que el requisito principal para 
poder administrar una máquina windows en Ansible es que ésta tenga instalado PowerShell 3 o superior.

Para simplificar el trabajo de preparar un host Windows, Ansible prové un script para instalar lo necesario, podemos
instalarlo vía powershell con los siguientes comandos:

```powershell
Invoke-WebRequest http://bit.ly/1rHMn7b -OutFile .\ansible-setup.ps1
.\ansible-setup.ps1
```

A tener en cuenta que el control host no requiere tener PowerShell instalado.


## Práctica 1: Preparar un host windows para Ansible

Primero de todo, los datos de acceso que necesitaremos para la máquina que creemos en AWS:

- Usuario: ```administrator```
- Password: ```C77l&iSP.2tZ$c;@jSK.=oEpEa(ipL8T```

Segundo, lanzaremos la VM desde nuestro control host, para ello, como usuario **root**:

1. Nos aseguraremos de tener clonado el repo de "laboratorio-jenkins-ansible" en nuestro control host en AWS


**Si no lo tenemos**
```text
cd && git clone http://gitlab.teradisk.net/trainings/laboratorio-jenkins.git
```

**Si lo tenemos**
```text
cd laboratorio-jenkins
git pull
```

2. Nos aseguramos de subir la clave ```curso-itnow.pem``` a ```/root/curso-itnow.pem``` de nuestro controller centos

**En el controller vagrant**

```scp -i curso-itnow.pem curso-itnow.pem centos@34.248.113.193:/tmp```

**En el controller de AWS** 

```text
mv /tmp/curso-itnow.pem /root
chmod 0600 /root/curso-itnow.pem
```

3. Creamos la VM windows desde el controller en AWS

```text
cd /root/laboratorio-jenkins
ansible-playbook crear-windows-aws.yml -e "NOMBRE_ALUMNO=Jordi"
```

Ahora nos conectaremos a la máquina windows via RDP, mediante los datos indicados más arriba y la IP que nos indique
la ejecución del playbook. A tener en cuenta que el arranque de una máquina windows toma su tiempo.

Lo siguiente, será lanzar, en una shell de powershell con derechos de administrador los siguientes comandos:

```powershell
Invoke-WebRequest http://bit.ly/1rHMn7b -OutFile .\ansible-setup.ps1
.\ansible-setup.ps1
```

![ejemplo instalar soporte PS](.img/powershell_preparar.png)

En principio nuestra VM windows está lista para ser administrada vía ansible, vamos a validarlo.

Añadamos al inventario las lineas que hacen falta para winrm:
```text
ansible_winrm_server_cert_validation = ignore
ansible_user = Administrator
ansible_password = C77l&iSP.2tZ$c;@jSK.=oEpEa(ipL8T
ansible_connection = winrm
```

Instalemos el soporte para winrm de python en el control host:

```text
pip install pywinrm
```

Y lancemos el siguiente comando para probar que funciona:

```text
ansible windows -i inventories/windows_Jordi.txt -m win_ping
```

La respuesta debería ser:

```text
34.241.1.191 | SUCCESS => {
    "changed": false, 
    "failed": false, 
    "ping": "pong"
}
```

## Módulos de Ansible para Windows

ver http://docs.ansible.com/ansible/latest/list_of_windows_modules.html


## Plantillando (jinja)

A tener en cuenta, cuando se haga una plantilla de un fichero para Windows, el retorno de carro es CR+LF.

## Práctica 2: Chocolatey

Chocolatey es un servicio que nos permite instalar paquetes para windows de forma similar a como lo hacemos en Linux.
Es un servicio de terceros, por lo que posiblemente no pueda aprovecharse en algunas organizaciones (aunque
existe la posibilidad de instalar un repositorio local de Chocolatey con soporte)

Deja el siguiente playbook en el fichero ```install-firefox.yml```

```yaml
- hosts: windows
  tasks:
  - name: Install firefox via chocolatey
    win_chocolatey:
      name: firefox
      state: present
```

Y ejecutalo mediante ```ansible-playbook -i inventories/windows_<NombreAlumno>.txt install-firefox.yml```

Verás que:
1. Ha instalado Chocolatey
2. Ha instalado Firefox

## Práctica 2: Windows Update

Ansible prevé un módulo para disparar el proceso de Windows Update.

Deja el siguiente playbook en el fichero ```update-windows.yml```

```yaml
- hosts: windows
  gather_facts: yes
  serial: 1 
  tasks:
    - name: install software security updates
      win_updates:
        category_names:
          - SecurityUpdates
          - CriticalUpdates
      register: update_result

    - name: reboot windows if needed
      win_reboot:
        shutdown_timeout_sec: 1200
        msg: "Due to security updates this host will be rebooted in 20 minutes."
      when: update_result.reboot_required
```

Y ejecutalo mediante ```ansible-playbook -i inventories/windows_Jordi.txt update-windows.yml ```

No debería encontrar updates (cosas de usar una imagen reciente de windows)

Ansible no prové una forma de instalar KB's individuales (de momento), pero se puede hacer mediante
la librería de PowerShell para Windows Update: https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc


## Práctica 3: Usuarios locales

Se pueden crear usuarios locales (y de dominio) con Ansible.

Deja el siguiente playbook en el fichero ```users-windows.yml```

```yaml
- hosts: windows
  gather_facts: no
  tasks:
    - name: create user groups
      win_group:
        name: "{{ item }}"
      with_items:
        - application
        - deployments

    - name: create users
      win_user:
        name: "{{ item.name }}"
        password: "{{ item.password }}"
        groups: "{{ item.groups }}"
        password_expired: "{{ item.password_expired | default(false) }}"
        groups_action: "{{ item.groups_action | default('add') }}"
      with_items:
        - name: gil
          password: t3lCj1hU2Tnr
          groups:
            - Users
            - deployments
        - name: sarina
          password: S3cr3t!
          password_expired: true
          groups:
            - Users
            - application
```

Y ejecutalo mediante ```ansible-playbook -i inventories/windows_Jordi.txt users-windows.yml```

Valida en Windows que ha creado los usuarios. Observa las diferencias de ajustes entre ellos.

## Práctica 4: IIS + Web

Vamos a hacer el equivalente a nuestro playbook favorito de NGINX y el site estático.

Esta vez con Windows, IIS y la web.

**Paso 1: Instalar IIS**

Podemos instalar IIS con el siguiente playbook:

```yaml
# This playbook installs and enables IIS on Windows hosts

- name: Install IIS
  hosts: all
  gather_facts: false
  tasks:
    - name: Install IIS
      win_feature:
        name: "Web-Server"
        state: present
        restart: yes
        include_sub_features: yes
        include_management_tools: yes
```

Este playbook reiniciará nuestro host Windows tras instalar IIS si es necesario.

Podemos validar que IIS responde accediendo a ```http://<ip>```

Ahora, desplegaremos el site estático que hay en 
```https://github.com/BlackrockDigital/startbootstrap-one-page-wonder```

El problema principal es que no hay módulo de GIT para Windows en Ansible. Tendremos que hacerlo de otra forma.
 
Vamos a hacer una primera versión de nuestro playbook que instale Git, llamaremos al playbook
```deploy-website-win.yml```:

```yaml
- hosts: windows
  tasks:
  - name: Install git via chocolatey
    win_chocolatey:
      name: git
      state: present
```

Ahora Git está instalado en ```C:\Program Files\Git\bin```, por lo que podríamos extender el playbook anterior
y dejarlo de la siguiente forma:

```yaml
- hosts: windows
  vars:
    git_url: "https://github.com/BlackrockDigital/startbootstrap-one-page-wonder.git"
    deploy_path: "C:\\inetpub\\wwwroot"
  tasks:
  - name: Install git via chocolatey
    win_chocolatey:
      name: git
      state: present
  - name: Clear old website
    win_file:
      path: "{{ deploy_path }}"
      state: absent
  - name: Deploy website
    win_command: '"C:\Program Files\Git\bin\git.exe" clone {{ git_url }} {{ deploy_path }}'
```

Vuelve a abrir la URL y debería aparecer la nueva página web.

