# LocalStack Development Environment

Environnement de développement avec LocalStack, OpenTofu, et AWS CLI local dans Docker.

## Prérequis

- Docker
- Docker Compose

## Démarrage

```bash
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

Vous pouvez travailler directement sur votre Mac dans le dossier `workspace/`. Les fichiers sont automatiquement synchronisés avec le container.

**Sur votre Mac :**
```bash
cd workspace/
# Créer/éditer vos fichiers Terraform avec VSCode ou votre éditeur préféré
code main.tf
```

**Exécuter les commandes dans le container :**
```bash
# Entrer dans le container
docker-compose exec localstack bash

# Dans le container, vos fichiers sont déjà synchronisés !
cd /workspace
tflocal init
tflocal apply
```

### Alias pour simplifier (optionnel)

Ajoutez à votre `~/.zshrc` (ou `~/.bashrc`) :

```bash
# Exécuter tflocal dans le container depuis votre Mac
alias tflocal='docker-compose -f /Users/lucassteichen/dev/epsi/terraform/docker-compose.yml exec localstack tflocal'

# Exécuter awslocal dans le container depuis votre Mac
alias awslocal='docker-compose -f /Users/lucassteichen/dev/epsi/terraform/docker-compose.yml exec localstack awslocal'
```

Puis rechargez : `source ~/.zshrc`

Maintenant vous pouvez exécuter directement depuis votre Mac :
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
# Arrêter le container
docker-compose down

# Arrêter et supprimer les données
docker-compose down -v
```

## Structure

```
.
├── Dockerfile              # Image personnalisée avec tous les outils
├── docker-compose.yml      # Configuration Docker Compose
├── workspace/              # Vos fichiers Terraform (synchronisé)
└── localstack-data/        # Données persistantes LocalStack
```
