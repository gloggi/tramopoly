# :train: Tramopoly :bus:

Webapp for the tramopoly game of Pfadikorps Glockenhof ⚜

## Project Setup

* Set up a free Supabase project.
* Optional: Take note of the database password, to access the database directly later.
* In the Supabase administration console:
  * Under authentcation -> Providers, set up keycloak authentication.
  * Optional: Under authentication -> Providers, open Phone and set up Twilio integration and activate "Enable phone confirmations", but don't activate "Enable Phone provider". Don't forget to save.
  * Under authentication -> URL Configuration, set Site URL to http://localhost:5173.
  * Under Project settings -> API, find your values for the Supabase project URL and API key.
* Copy the file .env to .env.local and fill in your Supabase project URL and API key.
  * If you set up Twilio integration with Supabase, set VITE_USE_TWILIO_PHONE_VERIFICATION in your .env.local to true

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
