
***

# Inception-of-Things : Guide des Notions Fondamentales par Étapes

##  Introduction : Le Vocabulaire de Base

| **Notion / Technologie** | **Explication Détaillée** |
| --- | --- |
| **Machine Virtuelle (VM)** | Un ordinateur "logiciel" qui tourne à l'intérieur de ton propre ordinateur. Elle possède son propre système d'exploitation (OS) et ses ressources isolées. |
| **Vagrant** | Un outil qui permet de créer, configurer et gérer des machines virtuelles automatiquement via un fichier texte appelé `Vagrantfile`. C'est comme du "Infrastructure as Code" : on décrit la machine en texte, et Vagrant la construit. |
| **Docker** | Une technologie de **conteneurisation**. Contrairement à une VM qui émule un ordinateur entier, un conteneur ne contient que l'application et ses dépendances. C'est beaucoup plus léger et rapide. |
| **Kubernetes (K8s)** | Le "chef d'orchestre" pour les conteneurs. Si tu as 100 conteneurs Docker, Kubernetes s'occupe de les démarrer, de les surveiller, de les relancer s'ils plantent et de gérer leur communication. |
| **K3s** | Une version **légère** de Kubernetes, optimisée pour consommer très peu de ressources (RAM/CPU). C'est idéal pour l'apprentissage ou les petits serveurs. |
| **K3d** | Un outil qui permet de faire tourner des clusters **K3s à l'intérieur de conteneurs Docker**. Cela permet de simuler un cluster Kubernetes entier sur ta machine sans avoir besoin de plusieurs VMs lourdes. |
| **kubectl** | L'outil en ligne de commande (CLI) indispensable pour parler à ton cluster Kubernetes et lui donner des ordres (créer une app, voir les logs, etc.). |

***

##  ÉTAPE 1 - PARTIE 1 : Vagrant, Réseau et K3s
*L'objectif de cette étape est de construire tes machines virtuelles, configurer leur réseau et installer les bases de ton cluster Kubernetes (Server et Worker).*

### La Virtualisation 
En informatique, la virtualisation consiste à créer une version logicielle d'une ressource physique. Pour ce projet, cela signifie créer une **Machine Virtuelle (VM)** : un ordinateur complet qui s'exécute de manière isolée à l'intérieur de ton propre ordinateur.
* **L'Isolation** : La VM a son propre système d'exploitation et ne peut pas interférer directement avec ton système principal.
* **L'Allocation de ressources** : Tu définis précisément ce que la VM peut utiliser, par exemple 1 CPU et 512 Mo de RAM.
* **L'automatisation avec Vagrant** : Au lieu de créer la VM à la main, tu utilises un fichier de configuration (`Vagrantfile`) pour que **Vagrant** s'en occupe automatiquement pour toi.

### Le Réseau 
Une fois que tes machines virtuelles sont créées, elles doivent pouvoir se parler et être accessibles depuis ton ordinateur. C'est là que le réseau intervient.
* **Adresse IP** : C'est la "carte d'identité" réseau de ta machine. Le projet impose des adresses spécifiques (ex: `192.168.56.110`) sur une interface réseau dédiée.
* **SSH (Secure Shell)** : C'est le protocole qui te permet de prendre le contrôle de ta machine à distance via un terminal, sans avoir besoin d'un écran virtuel, et ici, sans mot de passe.
* **Interfaces réseaux** : Les systèmes Linux modernes utilisent des noms prévisibles comme `enp0s8` au lieu des anciens noms comme `eth0` pour identifier les cartes réseaux.

### Le Fonctionnement de Vagrant
Vagrant fonctionne comme un chef d'orchestre pour la virtualisation. Au lieu de configurer chaque option dans une interface graphique (comme VirtualBox), tu écris tout dans un fichier texte appelé **Vagrantfile**.

Voici les trois piliers de son fonctionnement :
1. **Le Vagrantfile :** C'est ta "recette". Tu y définis l'OS (la distribution Linux), le nom des machines (ton login suivi de S ou SW), et les ressources comme le processeur (1 CPU) ou la mémoire vive (512 Mo ou 1024 Mo).
2. **Le Provider  :** Vagrant ne crée pas la machine lui-même. Il donne des ordres à un "fournisseur" de virtualisation (souvent VirtualBox) pour qu'il construise la VM selon ta recette.
3. **Le Provisioning :** C'est l'étape magique. Une fois la machine allumée, Vagrant peut exécuter automatiquement des scripts (shell) pour installer tes outils, comme **K3s** ou **kubectl**, sans que tu n'aies à taper une seule commande à l'intérieur de la machine.

### L'Anatomie du Vagrantfile
Comprendre l'anatomie d'un **Vagrantfile** est essentiel, car bien qu'il s'agisse d'un fichier de configuration, il utilise la syntaxe du langage **Ruby**.
* **Définition et Nom** : Pour gérer plusieurs machines (comme `S` et `SW`), on utilise des blocs `config.vm.define`. À l'intérieur, on définit le nom d'hôte (`hostname`) qui apparaîtra dans le terminal.
* **Réseau et IP ** : L'adresse IP fixe demandée (ex: `192.168.56.110`) se configure avec `vm.network`. On utilise généralement le mode "private_network".
* **Ressources (RAM/CPU) ** : Pour limiter la RAM (512 Mo) et le CPU (1 unit) , on doit entrer dans la configuration du "provider" (le logiciel qui fait tourner la VM, comme VirtualBox).

### Le Cycle de Vie et les Commandes
* **Le cycle de vie de `vagrant up`** : Lecture du Vagrantfile -> Vérification de la Box -> Création de la VM -> Configuration Réseau -> Provisionnement.
* **Le fonctionnement de `vagrant ssh` ** : Une fois les machines lancées, cette commande te permet d'y entrer via une authentification par clés (sans mot de passe).

### L'Automatisation (Provisioning) 
Le **provisionnement** est l'étape où Vagrant installe K3s sans intervention manuelle.
* **Sur le Server (wilS) ** : Le script installe K3s en mode "serveur" et récupère un **Token** unique (dans `/var/lib/rancher/k3s/server/node-token`).
* **Sur le Worker (wilSW)** : Le script installe K3s en mode "agent". Il a impérativement besoin de l'adresse IP du serveur (`192.168.56.110`) et du **Token**.

### L'Adressage IP et les Interfaces 
* **Réseau Privé** : La plage `192.168.x.x` est réservée aux réseaux locaux (privés).
* **IP Statique** : `192.168.56.110` pour le serveur et `192.168.56.111` pour le worker.
* **Noms Predictibles ** : Linux utilise des noms comme `enp0s8` ou `enp0s9` pour les cartes réseau.

### Manipulation des Commandes 
Pour vérifier l'état du réseau, on utilise la commande `ip a`.
* **inet** : Suivi de l'adresse IP (ex: `192.168.56.110/24`). **C'est l'info n°1**.
* **Flags** : Entre crochets `<UP,LOWER_UP,...>`. Indique si l'interface est active.

### Configuration dans Vagrant 
La syntaxe exacte pour définir l'IP statique demandée dans ton sujet :
```ruby
config.vm.network "private_network", ip: "192.168.56.110"
```

### Le Rôle de l'IP dans Kubernetes 
L'adresse IP **192.168.56.110** est le point d'ancrage central.
* **Le point de contact du Control Plane** : C'est ici que réside l'API Kubernetes.
* **L'ancrage pour les Workers** : L'agent doit se connecter activement au contrôleur via cette IP.
* **La porte d'entrée unique (Ingress) ** : C'est cette adresse qui servira de point d'entrée pour tes applications web.

### L'Accès SSH 
Pour se connecter sans mot de passe, on utilise la **cryptographie asymétrique** (Clé Publique et Clé Privée ). Vagrant génère, injecte et configure tout cela automatiquement.

### La Sécurité du Fichier de Configuration
Le fichier `/etc/ssh/sshd_config` assure la sécurité :
* **PubkeyAuthentication**  : Réglé sur `yes`.
* **PasswordAuthentication** : Réglé sur `no` (ferme la porte aux mots de passe).
* **PermitRootLogin**  : Souvent configurée sur `prohibit-password`.

### Le SSH entre le Serveur et le Worker 
**K3s n'utilise pas SSH** pour orchestrer ses workers.
* **L'Agent K3s** : Le programme `k3s-agent` tourne sur le worker et se connecte au serveur via l'IP `192.168.56.110`.
* **Le Tunnel HTTPS** : Ils communiquent via une API sécurisée (sur le port **6443**) et non via SSH.

### Vérification Manuelle 
Commandes pour inspecter tes clés SSH :
* `ls -la ~/.ssh/` : Liste tous les fichiers.
* `cat ~/.ssh/authorized_keys` : Affiche les clés autorisées.
* Les permissions doivent être très strictes (`600` pour les fichiers clés, `700` pour le dossier).

***

##  ÉTAPE 2 - PARTIE 2 : Kubernetes, Applications et Ingress
*L'objectif ici est de comprendre comment déployer des applications sur ta machine Serveur et les rendre accessibles depuis l'extérieur via des noms de domaine.*

###  L'Anatomie de Kubernetes
Pour faire tourner tes applications, tu vas manipuler des objets :
* **Le Pod** : La plus petite unité. Elle contient ton application (le conteneur).
* **Le Deployment** : C'est le gestionnaire. Il surveille les Pods et assure le bon nombre de réplicas.
* **Le Service** : L'adresse stable. Il possède une IP interne fixe et redirige le trafic vers les Pods.

### Le Réseau et l'Accès Externe 
Pour que ton navigateur affiche tes applications, plusieurs éléments collaborent :
1.  **L'IP du Nœud (192.168.56.110)** : L'adresse unique d'entrée.
2.  **L'Ingress Controller (Traefik)** : Installé par défaut dans K3s, il écoute les requêtes.
3.  **L'objet Ingress** : Contient les règles de routage (ex: "Si le visiteur demande `app1.com`, envoyez-le à l'app1").
4.  **Le Service** : Distribue le trafic vers les **Pods**.

### La Configuration YAML de l'Ingress 
Le fichier YAML définit le "plan de routage" :
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    kubernetes.io/ingress.class: "traefik"
spec:
  rules:
  - host: "app1.com" # Le nom de domaine que tu tapes
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-one-service # Le nom exact de ton Service
            port:
              number: 80
```

### Le Fichier `/etc/hosts` 
Pour tester localement, tu dois dire à ton propre ordinateur que `app1.com` correspond à ton IP :
* Ajoute la ligne : `192.168.56.110 app1.com` dans `/etc/hosts` (Linux/Mac) ou `C:\Windows\System32\drivers\etc\hosts` (Windows).

### Le Concept de "Default Backend"
C'est la règle de "dernier recours" de l'Ingress. Si une requête ne correspond ni à `app1.com` ni à `app2.com`, Traefik la redirige vers l'**application 3**, qui sert de service de secours.

***

##  ÉTAPE 3 - PARTIE 3 : K3d, Namespaces, Docker et Argo CD
*Dans cette dernière phase (sans Vagrant), tu vas isoler tes ressources dans des Namespaces et mettre en place un pipeline GitOps complet pour automatiser les mises à jour.*

### L'Organisation par Namespaces 
Un Namespace est comme une "partition virtuelle" dans ton cluster.
* Tu dois créer deux namespaces : `argocd` (pour l'outil) et `dev` (pour ton application).
* **Isolation** : Évite qu'une erreur de l'app n'impacte Argo CD.
* **Sécurité (RBAC)** : Permet de restreindre l'accès avec le principe du moindre privilège (Role, RoleBinding).
* **Quotas** : Permet de fixer des limites avec `ResourceQuota` (budget global) et `LimitRange` (taille individuelle par conteneur).

### Création et Gestion Pratique 
* **Créer**  : `kubectl create namespace dev`
* **Lister**  : `kubectl get namespaces`
* **Basculer de contexte**  : `kubectl config set-context --current --namespace=dev`

###  Le Workflow Moderne (Docker & GitOps)
Le dépôt GitHub devient la **source de vérité**.
1. **GitHub** : Stocke tes fichiers YAML.
2. **Argo CD** : Surveille GitHub et compare avec le cluster.
3. **Docker Hub** : Héberge les images de tes applications.
4. **K3d** : Ton cluster local qui exécute les Pods.

### La Création de l'Image (CI) 
Pour envoyer ton app sur Docker Hub :
1. **Dockerfile** : La recette de construction.
2. **Docker Build ** : Crée l'image.
3. **Tagging ** : Identifie les versions (`v1`, `v2`). Évite le tag `latest`.
4. **Docker Push** : Envoie l'image sur Docker Hub.

### La Magie d'Argo CD (CD) 
Argo CD "tire" (pull) les informations depuis Git via une boucle de réconciliation.
* **L'Anatomie du YAML "Application" ** :
    * `source` : Ton dépôt Git (`repoURL`, `targetRevision`, `path`).
    * `destination` : Où déployer (`server`, namespace `dev`).
* **L'Authentification du Dépôt** : Utilisation de HTTPS (Token) ou SSH (Clé privée) stockés dans des Secrets Kubernetes.
* **Auto-Sync** : Applique immédiatement la nouvelle configuration de GitHub vers le cluster.
* **Self-Healing** : Répare le cluster en écrasant toute modification manuelle pour revenir à la version Git.
* **Le Déclenchement Automatique** : Argo CD surveille GitHub via un **Polling** (sondage régulier) ou un **Webhook** (notification instantanée par GitHub).

### La Gestion des Versions (Passer de v1 à v2) 
Tout se joue dans le champ `image` du Deployment YAML (remplacer `:v1` par `:v2`).

* **Le Cycle de Vie et la Résilience** : Le Deployment maintient toujours l'état désiré (répare les Pods cassés).
* **Les Stratégies de Déploiement** :
    * **Rolling Update ** : Mise à jour progressive, sans coupure.
    * **Recreate** : Coupe tout puis relance (entraîne un temps d'arrêt).
* **Paramétrer la Transition ** :
    * `maxSurge` : Surplus autorisé pendant la mise à jour.
    * `maxUnavailable` : Tolérance de Pods hors service.
* **Les Sondes de Santé (Probes)** : La **Readiness Probe** vérifie si l'app `v2` fonctionne vraiment avant de supprimer l'ancienne `v1`.
* **Le Rollback** : En cas de problème, tu peux revenir instantanément à la version `v1` via l'interface d'Argo CD ou la commande `kubectl rollout undo`.