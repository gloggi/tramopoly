# :train: Tramopoly :bus:

Webapp for the tramopoly game of Pfadikorps Glockenhof ⚜

## Project Setup

* Set up a free Supabase project.
* Optional: Take note of the database password, to access the database directly later.
* In the Supabase administration console:
  * Under authentcation -> Providers, set up keycloak authentication.
  * Under authentication -> URL Configuration, set Site URL to http://localhost:5173.
  * Under Project settings -> API, find your values for the Supabase project URL and API key.
* Copy the file .env to .env.local and fill in your Supabase project URL and API key.

```sh
yarn
```

### Compile and hot-reload for development

```sh
yarn dev
```

### Compile and minify for production

```sh
yarn build
```

### Run unit tests with [Vitest](https://vitest.dev/)

```sh
yarn test:unit
```

### Lint with [ESLint](https://eslint.org/)

```sh
yarn lint
```
