# Dia 4 - Laboratorio 5 - Linting

## ¿Que es el linting?

Lint era un desarrollo en C que permitía comprobar fallos conocidos de estructura en el código antes de compilarlo
para evitar bugs o malas prácticas.

Al igual que el término "google" para hacer búsquedas, "Linting" se ha convertido en el término aplicado a todos los
programas que realizan la función del Lint original en varios lenguajes.

## Lint en Ansible

Ansible no prevé ninguna herramienta de lint de forma nativa. Existen los siguientes desarrollos de terceros que
proven esta funcionalidad:
- ansible-review : https://github.com/willthames/ansible-review
- ansible-lint : https://github.com/willthames/ansible-lint

Estas aplicaciones contienen un set de reglas / checks mínimos que validan que la estructura de YAML y de Ansible sean
correctas, así como las best practices indicadas en la documentación de Ansible.

## Probar ansible-review en uno de nuestros roles

Vamos a probar ansible-review en uno de nuestros playbooks, es fácil:

```text
ansible-review [playbook]
```

Si queremos analizar todos los ficheros de un rol:



