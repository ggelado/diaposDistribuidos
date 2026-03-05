---
title: "¿Cómo afrontar la práctica de Distribuidos?"
subtitle: "Sin pegarse un tiro ni pegarselo a nadie. Documento en redacción, revisa última versión."
author: "Gonzalo"
date: "Marzo 2026"
babel-lang: spanish
documentclass: beamer
classoption:
  - xcolor=dvipsnames
  - usepdftitle=false
header-includes:
  - \usepackage{presentation}

---

## Documentación

- Estas diapositivas: https://ggelado.github.io/diaposDistribuidos/diapos.pdf
- En documento para leer: https://ggelado.github.io/diaposDistribuidos/documento.docx

Este documento está en redacción, cada cambio actualiza los ficheros en esos enlaces.

Consulta regularmente la última versión en esos enlaces.

# Introducción

## ¿De qué va esto?

Va de que los 4 nodos de triqui (p.ej.) hablen entre ellos, se manden ficheritos, mensajitos y demás, pero que ninguno sea un servidor, **TODOS SON SERVIDORES Y CLIENTES**.

Eso es el P2P (lo que se hacía hace años con los torrents ilegales).

Ya lo iremos definiendo sobre la marcha.

## ¿Qué necesito?

- Entorno linux:
  
  - WSL
  
  - Máquina Virtual
  
  - Linux nativo
  
  - ¿Triqui? ¿Escritorios virtuales? (si tu paciencia y cordura lo permiten)

- Conexión con triqui

- Usar el Gestor de Entregas de Triqui (ya explicaré cómo funciona)

## ¿Empezamos?

1. Coge un editor cómodo (vas a dedicarle un ratito)
   
   - VSCode
   
   - CLion
   
   - ¿Nano? ¿vi? ¿emacs?

2- Pon tu entorno de trabajo

3- Enciende la VPN

# Arrancando

## Ficheros de Trabajo

Ejecuta en una terminal

```bash
wget https://laurel.datsi.fi.upm.es/_media/docencia/asignaturas
/sd/ring-2026.tgz
# 2 líneas para que no se corte
tar xvfz ring-2026.tgz
cd DATSI/SSDD/ring.2026/src/
```

De una

## Comunicación con Triqui

Vas a pasar muchas veces ficheros de triqui a tu ordenador y viceversa, puedes hacer SCP todo el rato, pero vas a deprimirte.

- [Bitvise](https://bitvise.com/ssh-client-download) (Mi preferido para Windows)

- [Uso Ubuntu nativo](https://itsupport.cs.uvic.ca/tutorials/linux_sftp/#:~:text=SFTP%20using%20Linux%20GUI%20File%20Browser%20(Nautilus))

O si no...

```bash
scp ficheroOrigen usuario@triqui.fi.upm.es:
~/DATSI/SSDD/ring.2026/src/

# 2 líneas para que no se corte
```

Usa esos programas, por favor, te salvan la vida.

## Gestor de Entregas

Funciona igual que en SSOO:

**ADVERTENCIA**: Por alguna razón el Gestor espera que los ficheros estén en `~/DATSI/SSDD/ring.2026/` pero los profes han puesto el código de la plantilla en `todoEso/src`, por lo que **falla**. Saca los ficheros de src y llévalos a esa carpeta.

Con Bitvise y demás es sencilla la operación.

## Gestor de Entregas (2)

Cada vez que queramos hacer una entrega:

1. Entrar en triqui

2. Poner **DONDE SEA** (en una terminal): `entrega.sd ring.2026`

3. Introducir el número de matrícula cuando se solicite

4. El corrector corre cada 3h y manda un correo

# A picar código

## ¿Dónde se toca?

- ring_cln.c

- ring_srv.c

- common.c

- include/common.h

Y ya está, el resto de ficheros se miran pero no se tocan.

## ¿Cómo empiezo?

Pues por el principio.

No empieces a leerte todo el enunciado, vamos por partes:

# Fase 1 - Paso 1

## Desplegar parte servidora

Vamos con el fichero `ring_cln.c`. 

**Objetivo**: 

- Debe guardar la información recibida en sus parámetros e implementarse la función ring_self a partir de ella.
- Debe crear el socket de servicio, para lo que puede usar la función create_socket_srv, tal como se hace en el ejemplo propuesto. Esa función devuelve el puerto seleccionado por el sistema operativo en formato de red, que, a su vez, debe ser devuelto por esta función.
- Debe crear el *thread* de servicio que ejecutará la función server_thread de ring_srv.c pasándole como argumento el socket de servicio. Para ello, puede usar la función create_thread de common.c, que crea un *thread* de tipo *detached*.

## ¿Qué tenemos?

Nos dan esto

```c
// inicia el nodo añadiéndolo a la red P2P si ya está creada;
// los puertos e IPs deben estar en formato de red;
// debe devolver en el último parámetro el puerto reservado en formato red;
// retorna 0 si OK y -1 si error
int ring_init(const char *shrd_dir, unsigned int local_ip, unsigned int remote_ip, unsigned short remote_port, unsigned short *alloc_port) {
    if (initialize()) return -1; // ya está inicializada
    return 0;
}
```

Hay params de **salida** (punteros):
- `unsigned short *alloc_port` es de **salida**

## Crear el socket de servicio

Del ejemplo `server.c`:

```c
if ((s=create_socket_srv(&port)) < 0) return 1;
```

Lo adaptamos en `ring_init`:

```c
int s;
if ((s = create_socket_srv(&port_copia)) < 0) return -1;
*alloc_port = port_copia;
```

`port_copia` ya tiene el valor para `ring_self`.

## Lanzar el thread servidor

Del ejemplo `server.c`:

```c
create_thread(request_handler, (void *)(long)s_conec);
```

Lo adaptamos:

```c
create_thread(server_thread, (void *)(long)s);
```


## La parte servidora: `ring_srv.c`

Adapta el bucle de `server.c`.

- El argumento llega como `(long)arg`
- Bucle `while(1)` con `accept`
- Por cada conexión: `create_thread` con el socket de conexión
- Devuelve `NULL` (es `void *`, no `int`)

## Prueba del Paso 1

```bash
mkdir dir1 && ./ring dir1
```

En otra terminal:

```bash
ss -tap | grep <puerto>
# debe aparecer LISTEN con el PID de ring
```

# Fase 1 - Paso 2

## Primera operación remota

**Objetivo**: que un nodo le pregunte el PID a otro.

Sin parámetros de entrada, devuelve un `int`.

## Códigos de operación

Antes de enviar nada hay que decirle al servidor **qué quieres**. Opciones:

- Carácter: `'P'`
- Entero: `0`
- String: `"GETPID"`

El `char` y el entero son los más cómodos para `switch` (en C no podemos hacerlo con un string).

## Parte cliente: `ring_remote_pid`

```c
char op = 'P';
send(s, &op, sizeof(char), 0);

int pid;
recv(s, &pid, sizeof(int), MSG_WAITALL);
close(s);
return ntohl(pid);
```

## Conectar con IP y puerto en formato de red

`create_socket_cln` espera strings. Aquí tenemos enteros en formato red:

```c
struct sockaddr_in addr;
addr.sin_family      = AF_INET;
addr.sin_addr.s_addr = remote_ip;  // formato red
addr.sin_port        = remote_port; // formato red

int s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
connect(s, (struct sockaddr *)&addr, sizeof(addr));
```

Vas a usar esto en **todas** las operaciones remotas..

## Parte servidora

```c
char op;
recv(soc, &op, sizeof(char), MSG_WAITALL);

switch(op) {
    case 'P': {
        int pid = htonl(getpid());
        write(soc, &pid, sizeof(int));
        break;
    }
}
close(soc);
return NULL;
```

## Prueba del Paso 2

```bash
./ring dir1
# pulsa P, introduce la IP y puerto del propio nodo
```

```
PID 2576024
```

Debe coincidir con el PID del mensaje de bienvenida.

# A currar

## Haz funcionar esto

![](assets/2026-03-04-19-37-23-image.png)
