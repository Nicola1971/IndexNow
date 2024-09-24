# IndexNow Plugin for Evolution CMS

**Requirements**: This plugin requires Evolution CMS 1.4 or later

### What is IndexNow? 
IndexNow is an easy way for websites owners to instantly inform search engines (Bing, Yandex, Naver) about latest content changes on their website.

### More About IndexNow:
https://www.indexnow.org/

https://www.bing.com/indexnow

## Installation:

- Install with Evo Extras Module
- Assign InstallNow Template Variable to your templates

**IndexNow TV**:  

![indextv](https://github.com/user-attachments/assets/f9344815-a0f4-4f9d-aa33-293d61f10649)


## Configuration
![indexnow-conf](https://github.com/user-attachments/assets/0fa062ec-bd9e-4631-80b1-56edaa02ccb8)


**IndexNow Key**: Your IndexNow API key (to generate API key go to https://www.bing.com/indexnow/getstarted or https://webmaster.yandex.ru/)

**IndexNow TV ID**: ID of IndexNow Teemplate variable

**Reset IndexNow TV after sending**: If if enabled, after receive a positive confirmation from IndexNow, the plugin reset the IndexNow Template variable. If the submission to IndexNow returns an error message the template variable is not reset.

**Exclude Documents by id (comma separated)**: A list of documents id to exclude from sending to IndexNow 

**Exclude Templates by id (comma separated)**: A list of templates id to exclude from sending to IndexNow 

**Enable documents sent and errors logs**: Check the sending result and log the message to Evo Events Log

**Enable documents excluded logs**: Send info about excluded documents report to logs (doc id, template id and Tv value)

