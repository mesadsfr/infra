# Infra mesads.beta.gouv.fr

Ce repository contient le code nécessaire pour gérer l'infrastructure de mesads.beta.gouv.fr.

## backup-db

L'image backup-db sauvegarde la base de données de production de mesads.beta.gouv.fr (hébergée sur Clever Cloud) dans un bucket S3 hébergé sur Scaleway. L'image est exécutée en utilisant la fonctionnalité "jobs" de Scaleway.

## backup-d3

L'image backup-s3 utilise `rcon` pour synchroniser le bucket s3 de production (hébergé sur Clever Cloud) dans un bucket S3 hébergé sur Scaleway. L'image est exécutée en utilisant la fonctionnalité "jobs" de Scaleway.