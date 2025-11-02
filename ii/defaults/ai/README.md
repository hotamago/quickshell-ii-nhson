# AI Configuration

## Custom Models

You can add custom OpenAI-compatible models by configuring them in your `config.json`:

```json
{
  "ai": {
    "extraModels": [
      {
        "name": "My Custom Model",
        "model": "my-model-name",
        "endpoint": "https://my-api-provider.com/v1/chat/completions",
        "requires_key": true,
        "key_id": "my-provider",
        "api_format": "openai",
        "defaultTemperature": 0.7,
        "extraParams": {
          "max_tokens": 4096
        },
        "description": "Custom model description",
        "icon": "api",
        "homepage": "https://my-provider.com",
        "key_get_link": "https://my-provider.com/keys",
        "key_get_description": "Get your API key from the provider website"
      }
    ]
  }
}
```

### Model Configuration Options

- `name`: Display name for the model
- `model`: The model identifier/name used in API calls
- `endpoint`: API endpoint URL (defaults to OpenAI's endpoint)
- `requires_key`: Whether this model needs an API key (default: true)
- `key_id`: Identifier for the API key (used for storage)
- `api_format`: API format - "openai", "gemini", or "mistral" (default: "openai")
- `defaultTemperature`: Default temperature for this model (default: 0.7)
- `extraParams`: Additional parameters to send with API requests
- `description`: Description shown in model selection
- `icon`: Icon name from the icon set
- `homepage`: Link to model/provider homepage
- `key_get_link`: Link to get API keys
- `key_get_description`: Instructions for getting API keys

### Supported API Formats

- **OpenAI**: Compatible with OpenAI API format
- **Gemini**: Google's Gemini API format
- **Mistral**: Mistral AI API format

## System Prompts

## A note about sources of the prompts

- `ii-` prefixed ones are from illogical impulse
- The Acchan one is from [Nyarch Assistant](https://github.com/NyarchLinux/NyarchAssistant) (GPLv3). I know there's already the Imouto one but this one's very 😭💢
- `w-` prefixed ones... I don't remember what w stands for but these prompts are [*cough cough*] inspired by certain apps
