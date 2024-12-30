# Email JSON Extractor

## Setup

### 1. Clone or download this repository.

Clone the repository

```bash
git clone git@github.com:MartinM1312/email-json-extractor.git

cd email_json_extractor
```

### 2. Install gems

Run the following command

```bash
bundle install
```

### 3. Start the rails server

run

```bash
rails s
```

## Using the app

### 1. Endpoints

#### POST /emails/parse

This is the enpoint that receives a file path or URL to an
.eml file, parses it, follows any relevant links, and
returns the first JSON found.

### 2. params

`email_source (string)` This param should contain the path
to a local .eml file or a URL pointing to a .eml file.

### 3. running the app

First make sure your Rails app is running locally on, for
example, http://localhost:3000

you can use the `.eml` files inside
[this folder](app/assets/test_files/) to test the
application and check the json response.

### Using the rails console

You can test the service using the rails console by just
executing:

```bash
JsonExtractor.call('/Users/you/Downloads/
test_email.eml')
```

### Using curl

You can test the endpoint using curl like this:

```bash
curl -X POST \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "email_source=/Users/you/test_email.eml" \
     http://localhost:3000/emails/parse
```

After executing this, the application should return the
content of the JSON file found on the email. If no JSON is
found, you’ll get:

```bash
{
  "error": "No JSON found in the email or link chain"
}
```

### Using postman

#### Create a New Postman Request

1. Open Postman and click + to create a new request tab.
2. Set the Method to POST.
3. Enter the URL:

```bash
http://localhost:3000/emails/parse
```

#### Configure the Body

Because we’re sending a simple parameter (email_source), you
can use either form-data or x-www-form-urlencoded.

1. Click the Body tab in Postman.
2. Select x-www-form-urlencoded.
3. In the key column, enter email_source.
4. In the value column, enter either:
   - A local file path (e.g.
     /Users/jane.doe/Desktop/test_email.eml).
   - An HTTP URL to an email file (e.g.
     https://example.com/path/to/test_email.eml).

#### Click Send

If the service finds a .json attachment or a link to JSON,
you should see a 200 OK status with the parsed JSON in the
response body.

### 5. Running tests

To run the rspec tests just run:

```bash
bundle exec rspec
```

Or if you're using a recent ruby version just:

```bash
rspec
```
