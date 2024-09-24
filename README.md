# IndexNow Plugin for Evolution CMS

**Requirements**: This plugin requires Evolution CMS 1.4 or later

### What is IndexNow? 
IndexNow is indeed a useful tool for website owners. It allows them to quickly notify search engines like Bing, Yandex, and Naver about any changes to their website content. This helps ensure that the latest updates are reflected in search results much faster than traditional crawling methods.

### More About IndexNow:
https://www.indexnow.org/

https://www.bing.com/indexnow

## Installation:

- Go to https://www.bing.com/indexnow/getstarted (or https://webmaster.yandex.ru/) and generate the API key
- Upload the txt api key to the root of your website
- Install IndexNow plugin with Evo Extras Module
- Assign InstallNow Template Variable to your templates

**IndexNow TV**:  

![indextv](https://github.com/user-attachments/assets/f9344815-a0f4-4f9d-aa33-293d61f10649)


## Configuration
![indexnow-conf](https://github.com/user-attachments/assets/0fa062ec-bd9e-4631-80b1-56edaa02ccb8)


**IndexNow Key**: Your IndexNow API key 

**IndexNow TV ID**: ID of IndexNow Teemplate variable

**Reset IndexNow TV after sending**: If if enabled, after receive a positive confirmation from IndexNow, the plugin reset the IndexNow Template variable. If the submission to IndexNow returns an error message the template variable is not reset.

**Exclude Documents by id (comma separated)**: A list of documents id to exclude from sending to IndexNow 

**Exclude Templates by id (comma separated)**: A list of templates id to exclude from sending to IndexNow 

**Enable documents sent and errors logs**: Check the sending result and log the message to Evo Events Log

**Enable documents excluded logs**: Send info about excluded documents report to logs (doc id, template id and Tv value)

