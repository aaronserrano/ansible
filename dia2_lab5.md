# Dia 2 - Laboratorio 5

El objetivo de este laboratorio es aprender como aprovechar las iteraciones para ahorrarnos escribir código.

Crearemos el típico playbook en el que instalaremos las herramientas mínimas que cualquier servidor que se precie
debe tener instaladas:
- vim
- nano
- wget
- telnet
- net-tools
- httpry
- sysstat
- bc 
- lsof
- bind-utils
- lftp
- mlocate
- bash-completion 
- iptraf
- iotop
- ioping
- unzip
- man
- iftop
- rsync

Se puede reciclar código de otros laboratorios anteriores.


## Arrancar el laboratiorio

```bash
ansible-playbook crear-lab5s2.yml
```

Tras unos segundos este playbook habrá creado 1 máquina Centos 7, podéis ver su IP's en el 
fichero ```inventories/dia2lab5.yml```

Para acceder a ellas podréis hacerlo mediante el usuario "centos", con la clave pública que
se os ha dado justo con el fichero aws_vault.yml

Recomendamos dejar la clave pública en el directorio $HOME del usuario que vayáis a usar 
en la VM de laboratorio que se usa para control. De esta forma los comandos de la documentación
se ajustarán al entorno.

Ejemplo de comando para acceder a una de las máquinas de lab:

```ssh -i $HOME/curso-itnow.pem centos@a.b.c.d```

## Ejercicio 1 - Crear el rol

Vamos a crear el rol directamente, no lo haremos con un playbook "monolítico".
Desde la raíz del repo del curso, ejecutaremos

```bash
mkdir -p roles/basictools/tasks
```

Y editaremos el fichero roles/basictools/tasks/main.yml

```yaml
- name: install basic packages
  yum:
    name: "{{ item }}"
    state: present
  with_items:
    - vim
    - nano
    - wget
    - telnet
    - net-tools
    - httpry
    - sysstat
    - bc 
    - htop
    - lsof
    - bind-utils
    - lftp
    - mlocate
    - bash-completion 
    - iptraf
    - iotop
    - ioping
    - unzip
    - man
    - iftop
    - rsync
```

## Ejercicio 2 - refactor del rol

El rol queda un poco sucio, además si instalamos cada vez más paquetes... se nos puede volver difícil de ver.

Vamos a poner los paquetes que queremos en un array.

Para ello, crearemos la carpeta de defaults del rol

```bash
mkdir -p roles/basictools/defaults
```

Editaremos el fichero roles/basictools/defaults/main.yml

```yaml
packages:
  - vim
  - nano
  - wget
  - telnet
  - net-tools
  - httpry
  - sysstat
  - bc 
  - htop
  - lsof
  - bind-utils
  - lftp
  - mlocate
  - bash-completion 
  - iptraf
  - iotop
  - ioping
  - unzip
  - man
  - iftop
  - rsync
```

Y refactorizaremos el fichero roles/basictools/tasks/main.yml

```yaml
- name: install basic packages
  yum:
    name: "{{ item }}"
    state: present
  with_items: "{{ packages }}"
```

## Ejercicio 3: crear el playbook

Creemos el playbook ```d2l5_paquetes_minimos.yml``` que aplique el rol.

Lo ejecutamos:

```bash
ansible-playbook -i inventories/dia2lab5.yml d2l5_paquetes_minimos.yml
```

Posiblemente os falle. Si no os falla es que habéis estado atentos todo el curso.

En cualquier caso, si os falla deberíais ser capaces de localizar donde está el problema (debate abierto)



# Fin del laboratorio

En este laboratorio se habrán adquirido los siguientes conocimientos:
- Uso de los bucles para tareas repetitivas
- Refactorización de código para mejor legibilidad del mismo

Procederemos a la destrucción del laboratorio:

```bash
ansible-playbook borrar-labs5s2.yml
```