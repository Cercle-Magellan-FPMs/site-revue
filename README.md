# Revue des Mines 2028

Site vitrine « Coming Soon » en **Astro statique** pour la Revue des Mines de la Faculté Polytechnique de Mons.

## Développement local

Prérequis : Node.js 22 ou version LTS compatible.

```sh
npm install
npm run dev
npm run build
```

Les pages compilées sont écrites dans `dist/`. Aucun serveur Node.js n'est nécessaire pour les servir.

## Déploiement Dokploy (recommandé)

Le dépôt contient un `Dockerfile` multi-stage :

1. Compilation Astro avec Node.js 22 Alpine.
2. Copie des fichiers `dist/` dans **NGINX Alpine non privilégié**.
3. Exécution de NGINX sur le **port interne 8080**, sans Node.js en production.

Créer une **Application** dans Dokploy :

| Paramètre | Valeur |
| --- | --- |
| Source Git | `https://github.com/Cercle-Magellan-FPMs/site-revue` |
| Branch | `main` |
| Build Type | `Dockerfile` |
| Dockerfile Path | `Dockerfile` |
| Docker Context / Root Directory | `.` |
| Container / Target Port | `8080` |
| Start command | Laisser vide (image NGINX) |
| Variables d'environnement | Aucune nécessaire |
| Volumes | Aucun |

Cliquer sur **Deploy**. Dans l'onglet **Domains**, renseigner le domaine souhaité et pointer vers le port interne **8080**. Le TLS / HTTPS est à terminer sur le reverse proxy, sans nécessiter de certificat dans le conteneur. Pour les déploiements futurs, activer **Auto Deploy** sur la branche `main` si souhaité.

**Si le HTTPS est déjà terminé par un reverse proxy externe (par ex. Nginx Proxy Manager)** : conserver ce proxy existant. Il doit pouvoir joindre l'application Dokploy via une route ou un port publié adapté. Ne pas exposer directement le conteneur à Internet si le reverse proxy peut le joindre en réseau privé.

### Vérification locale avec Docker

```sh
docker build -t site-revue:local .
docker run --rm -d --name site-revue-test -p 127.0.0.1:8080:8080 site-revue:local
curl -I http://127.0.0.1:8080/
curl -f http://127.0.0.1:8080/healthz
docker stop site-revue-test
```

Le `HEALTHCHECK` Docker interroge `/healthz` toutes les 30 secondes. Ce point de contrôle répond `ok` sans appel extérieur.

### Fonctionnement et cache

- NGINX répond aux pages statiques et renvoie une vraie erreur HTTP 404 sur les URL inconnues.
- Les assets versionnés dans `/_astro/` sont mis en cache 1 an ; les images publiques, 1 jour.
- Compression gzip du texte ; en-têtes de sécurité basiques.
- Aucun service Node.js, aucune base de données et aucun secret en production.
- L'image du héros du site peut dépendre d'une ressource hébergée par la Fédé ; elle n'est pas nécessaire à la santé du conteneur.

**Note reproductibilité :** le projet ne contient pas encore de `package-lock.json`. L'étape de construction utilise donc `npm install` (et non `npm ci`). Après génération et commit d'un lockfile, il est conseillé de passer à `npm ci` pour figer les dépendances.

## Alternative : Vercel

Le projet reste compatible avec Vercel : framework `Astro`, commande `npm run build`, dossier `dist`.

La date exacte, le thème et la billetterie de la prochaine Revue ne sont pas encore annoncés.
