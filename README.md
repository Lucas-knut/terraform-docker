# LocalStack Development Environment

Environnement de développement avec LocalStack, OpenTofu, et AWS CLI local dans Docker.

## Prérequis

- Docker
- Docker Compose

## Installation

```bash
# Cloner le projet
git clone <url-du-repo>
cd terraform

# Créer le dossier workspace s'il n'existe pas
mkdir -p workspace

# Build et démarrer le container
docker-compose up -d --build

# Vérifier que le container tourne
docker-compose ps

# Voir les logs
docker-compose logs -f
```

## Accès au container

```bash
# Entrer dans le container
docker-compose exec localstack bash

# Vérifier les outils installés
tofu --version
tflocal --version
awslocal --version
python3 --version
```

## Utilisation

### Workflow de travail

Les fichiers dans le dossier `workspace/` sont automatiquement synchronisés avec le container grâce aux volumes Docker.

**Édition des fichiers :**
```bash
cd workspace/
# Créer/éditer les fichiers Terraform avec votre éditeur préféré
touch main.tf  # ou vim, nano, etc.
```

**Exécution des commandes :**

**Option 1 - Directement dans le container :**
```bash
# Entrer dans le container
docker-compose exec localstack bash

# Dans le container, vos fichiers sont synchronisés dans /workspace
cd /workspace
tflocal init
tflocal apply
```

**Option 2 - Avec des alias (recommandé) :**

Ajoutez ces alias à votre fichier de configuration shell (`~/.zshrc` ou `~/.bashrc`) :

```bash
# Exécuter tflocal dans le container
alias tflocal='docker-compose exec localstack tflocal'

# Exécuter awslocal dans le container
alias awslocal='docker-compose exec localstack awslocal'
```

Rechargez votre configuration : `source ~/.zshrc`

Vous pouvez maintenant exécuter les commandes directement depuis votre machine hôte :
```bash
cd workspace/
tflocal init
awslocal s3 ls
```

### Tester AWS Local

```bash
# Créer un bucket S3
awslocal s3 mb s3://test-bucket

# Lister les buckets
awslocal s3 ls
```

### Tester Terraform/OpenTofu

Créez vos fichiers `.tf` dans le dossier `workspace/` (synchronisé avec le container).

```bash
cd /workspace
tflocal init
tflocal plan
tflocal apply
```

## Arrêt

```bash
# Arrêter le container (conserve les données)
docker-compose down

# Arrêter et supprimer les données persistantes
docker-compose down -v
```

## Persistence des données

Le dossier `localstack-data/` stocke toutes les ressources AWS créées dans LocalStack (buckets S3, tables DynamoDB, etc.). Cela permet de **conserver vos données entre les redémarrages** du container.

**Exemple :**
```bash
# Créer un bucket S3
awslocal s3 mb s3://mon-bucket
awslocal s3 cp fichier.txt s3://mon-bucket/

# Arrêter le container
docker-compose down

# Redémarrer
docker-compose up -d

# ✅ Le bucket existe toujours !
awslocal s3 ls s3://mon-bucket/
```

**Pour repartir de zéro :**
```bash
# Supprimer toutes les données LocalStack
docker-compose down -v
rm -rf localstack-data/
```

## Structure du projet

```
.
├── Dockerfile              # Image personnalisée avec tous les outils
├── docker-compose.yml      # Configuration Docker Compose
├── .gitignore             # Fichiers à ignorer par Git
├── README.md              # Documentation du projet
├── workspace/             # Fichiers Terraform (synchronisé avec le container)
│   └── *.tf              # Vos fichiers de configuration Terraform
└── localstack-data/       # Données persistantes LocalStack (généré automatiquement)
```

**Note :** Le dossier `workspace/` doit être créé manuellement après le clonage. Les dossiers `localstack-data/` et les fichiers Terraform temporaires sont automatiquement ignorés par Git (voir `.gitignore`).

## Outils disponibles dans le container

- **OpenTofu** (v1.10.8) : Alternative open-source à Terraform
- **tflocal** : Wrapper pour OpenTofu/Terraform avec LocalStack
- **awslocal** : Wrapper pour AWS CLI avec LocalStack
- **LocalStack** : Émulation locale des services AWS
- **Python 3** : Pour scripts et outils additionnels

## Services AWS émulés

Par défaut, les services suivants sont activés :
- S3 (stockage)
- DynamoDB (base de données NoSQL)
- Lambda (fonctions serverless)
- SQS (files d'attente)
- SNS (notifications)
- EC2 (machines virtuelles)

Pour modifier les services, éditez la variable `SERVICES` dans `docker-compose.yml`. workspace/              # Vos fichiers Terraform (synchronisé)
└── localstack-data/        # Données persistantes LocalStack
```
