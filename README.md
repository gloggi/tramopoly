# <img src="tramopoly.gif" alt="Tramopoly">
<p align="center">Webapp for the tramopoly game of Pfadikorps Glockenhof :tram: :bus: ⚜</p>

## Project Setup

* Update the joker stations and their rewards and bonus questions in /supabase/seeds.sql
* Using the [open data set of the city of Zürich](https://data.stadt-zuerich.ch/dataset/ktzh_haltestellen_des_oeffentlichen_verkehrs___ogd_), update mr_t_locations in /supabase/seed.sql with all currently available stations in the city
* Find a free Supabase project which still uses Postgres 15 - on Postgres 17, the plv8 extension is not supported anymore, and this extension is required to run the tramopoly code.
* Take note of the database password you used, to set up the database structure later.
* In the Supabase administration console:
  * Under Authentication -> Sign In / Providers, disable the Email provider
  * Under Authentcation -> Sign In / Providers, set up keycloak authentication according to the [documentation](https://supabase.com/docs/guides/auth/social-login/auth-keycloak).
    * You'll have to send the callback URL (https://<project-ref>.supabase.co/auth/v1/callback) to Clever from ITKom so he can add it to the PBS Keycloak (id.scout.ch), and he will provide the Client ID, Secret and Realm URL in return.
  * Under Authentication -> Providers, open Phone and set up [Twilio Verify integration](https://supabase.com/docs/guides/auth/phone-login/twilio) and activate "Enable phone confirmations", but don't activate "Enable Phone provider".
    * During a typical Gloggi Tramopoly, you will need credits to send around 40 messages. For development, you might need roughly 20-40 more. So around 5-10 CHF of credits should suffice. Careful: Just having the account idle for the rest of the year will cost USD 1.15 per month. So in total, SMS costs up to 20.- per year, and coincidentally 20.- is also the minimum amount which you can add to your Twilio balance.
    * Don't forget to save.
  * Under authentication -> URL Configuration, set Site URL to your productive URL, and add http://localhost:5173 and http://localhost:4173 as Redirect URLs.
  * Under SQL editor -> New query, paste the contents of all files from supabase/migrations, and then supabase/seed.sql. If that sounds like too much work, see below for how to do this step using the supabase CLI instead.
  * Under Database -> Publications -> 0 tables, activate the toggle on the `abteilungen`, `groups`, `joker_visits`, `jokers`, `message_files`, `messages`, `mr_t_changes`, `mr_t_rewards`, `profiles`, `settings`, `station_visits` and `unseen_chat_activity` tables.
  * Under Project settings -> API Keys, use the Create new API keys button to find your API key under "Publishable key".
* Create a copy of the file .env, name it .env.local and fill in your Supabase project URL and API key.
  * If you set up Twilio integration with Supabase, set VITE_USE_TWILIO_PHONE_VERIFICATION in your .env.local to true, otherwise leave it empty (never `false`)
* In a terminal, run:
  * `yarn`
* To deploy:
  * `yarn build`
  * Upload the contents of the generated `dist` directory to your webserver
* After you first logged in, go in Supabase to Table Editor -> profiles and set the role on the profile which was created for you to `admin`. This allows you to manage all other users in the Tramopoly UI.

### Setting up the database structure using the supabase CLI

If you don't want to copy-paste the contents of all migrations files, you can instead use the supabase CLI to do so. Fair warning: The CLI isn't exactly easy to use. It might be easier to just paste the SQL code into the editor.

* In the Supabase administration console:
  * Take note of your project id. It should be in the URL, and should be a 20-character random string.
  * Under your profile avatar -> Account preferences -> Access Tokens, create an access token for setting up the initial database structure
* In a terminal, run:
  * `yarn`
  * `yarn supabase login` (enter your organization access token)
  * `yarn supabase link --project-ref <your project reference>` (replace the project id with yours, and enter your database password)
  * `yarn supabase db push`
* You still have to manually paste the contents of supabase/seed.sql into the SQL editor (or apply it using the `psql` command line client)

If you've made it this far, during development you can also create new migrations by editing the database structure in the online editor, and then running:
```bash
yarn create-migration
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
