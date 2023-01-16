# <img src="tramopoly.gif" alt="Tramopoly">
<p align="center">Webapp for the tramopoly game of Pfadikorps Glockenhof :tram: :bus: ⚜</p>

## Project Setup

* Set up a free Supabase project.
* Take note of the database password you used, to set up the database structure later.
* In the Supabase administration console:
  * Under authentcation -> Providers, set up keycloak authentication according to the [documentation](https://supabase.com/docs/guides/auth/social-login/auth-keycloak).
  * Optional: Under authentication -> Providers, open Phone and set up [Twilio integration](https://supabase.com/docs/guides/auth/phone-login/twilio#finding-your-twilio-credentials) and activate "Enable phone confirmations", but don't activate "Enable Phone provider". Don't forget to save.
  * Under authentication -> URL Configuration, set Site URL to your productive URL, and add your productive URL and http://localhost:5173 as Redirect URLs.
  * Under SQL editor -> New query, paste the contents of **each except the first file** from supabase/migrations, and then supabase/seed.sql. If that sounds like too much work, see below for how to do this step using the supabase CLI instead.
  * Under Database -> Replication -> 0 tables, activate the toggle on the `abteilungen`, `groups`, `message_files`, `messages`, `mr_t_rewards`, `profiles`, `settings` and `station_visits` tables.
  * Under Database -> Extensions, enable the PLV8 extension.
  * Under Project settings -> API, find your values for the Supabase project URL and API key.
* Create a copy of the file .env, name it .env.local and fill in your Supabase project URL and API key.
  * If you set up Twilio integration with Supabase, set VITE_USE_TWILIO_PHONE_VERIFICATION in your .env.local to true
* In a terminal, run:
  * `yarn`

### Setting up the database structure using the supabase CLI

If you don't want to copy-paste the contents of all migrations files, you can instead use the supabase CLI to do so. Fair warning: The CLI isn't exactly easy to use. It might be easier to just paste the SQL code into the editor.

* In the Supabase administration console:
  * Take note of your project id. It should be in the URL, and should be a 20-character random string.
  * Under your Supabase organization -> Access Tokens, create an access token for setting up the initial database structure
* In a terminal, run:
  * `yarn`
  * `yarn supabase login` (enter your organization access token)
  * `yarn supabase link --project-ref <your project reference>` (replace the project id with yours, and enter your database password)
  * `yarn supabase db push`
* You still have to manually paste the contents of supabase/seed.sql into the SQL editor (or apply it using the `psql` command line client)

If you've made it this far, during development you can also create new migrations by editing the database structure in the online editor, and then running:
```bash
yarn supabase db remote commit
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
