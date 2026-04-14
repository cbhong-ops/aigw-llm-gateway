import express from 'express';
import axios from 'axios';
import https from 'https';
import { GoogleAuth } from 'google-auth-library';
import { propertiesReader } from 'properties-reader';
const properties = propertiesReader({ sourceFile: 'eval.properties' });

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true })); 

async function getGoogleAccessToken() {
  const auth = new GoogleAuth();
  const scopes = ['https://www.googleapis.com/auth/cloud-platform']; // Define required scopes

  const client = await auth.getClient({ scopes: scopes });
  const accessToken = await client.getAccessToken();
  console.log('Access Token:', accessToken.token);
  return accessToken.token;
}




app.get('/echo', async (req, res) => {

        const target_ip = "10.128.0.82";

        const targeturl = 'http://'+target_ip+':3000/echo';
        console.log(properties.get('gpt-4.1-mini.primary.provider'))

        axios.get(targeturl)
        .then(response => {
                console.log('Response:', response.data);
                res.status(response.status).send(response.data);
        })
        .catch(error => {
                console.error('Error:', error);
                res.status(error.response.status).send(error.response.data);
        });

});

app.post('/chat/completions', async (req, res) => {
        
        //const decode_inference_profile_arn = decodeURIComponent(inference_profile_arn);
        //console.log('first profile: ' + decode_inference_profile_arn);
        //decodeURIComponent(apikey)

        const model = req.body.model;
        const hostname = req.hostname;

        console.log('request model: ' + model)
        console.log('hostname: ' + hostname)

        const arr = hostname.split('.');
        const provider = properties.get(model + '.' + arr[0] + '.provider');
        const targetmodel = properties.get(model + '.' + arr[0] + '.model');
        const url = properties.get(model + '.' + arr[0] + '.url');
        const targethost = properties.get(model + '.' + arr[0] + '.hostname');
        const targeturl = 'https://'+targethost+url;
        const apikey = properties.get(model + '.' + arr[0] + '.apikey');
        var token;

        if( provider == 'google' ){
            token = await getGoogleAccessToken();
        }else{
            token = apikey;
        }

        req.body.model = targetmodel;  // update model with target modelid
        var dataToSend = req.body;


        const postData = JSON.stringify(dataToSend);
        console.log(JSON.stringify(postData, null, 2));

        console.log('targetmodel: ' + targetmodel);
        console.log('access token: ' + token);
        console.log('targeturl: ' + targeturl);
        console.log('req.body: ' + JSON.stringify(dataToSend));


        // http request options
        const options = {
            hostname: targethost,
            port: 443,
            path: url,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + token
            }
        };

        // Send http request to Backend server
        const backendRequest = https.request(options, (backendResponse) => {
            let responseBody = '';

            if (backendResponse.statusCode !== 200) {
                console.error(`Backend Error - StatusCode: ${backendResponse.statusCode}`);

                // clientResponse.status(backendResponse.statusCode).json({
                res.status(502).json({
                    error: 'Bad Gateway - Backend Error',
                    message: backendResponse.statusMessage,
                    backendStatus: backendResponse.statusCode
                });
                // console.error(`Return to Client - StatusCode: 502`);
                return; 
            }


          // SSE Response Header
          res.writeHead(200, {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
          });

          backendResponse.pipe(res);
              







            // backendResponse.on('data', (chunk) => {
            //     res.write(chunk);
            //     console.log(`BODY: ${chunk}`);
            // });

            // backendResponse.on('end', () => {
            //     res.end();
            //     console.log('No more data in response.');
            // });
        });

        backendRequest.on('error', (error) => {
            console.error('Backend Connect Error :', error);
            // console.error(`Return to Client - StatusCode: 504`);
            if (!res.headersSent) {
                res.status(504).json({
                    error: 'Gateway Error',
                    message: 'Failed to connect to Backend'
                });
            }
        });
        
        backendRequest.write(postData);

        // finish the request to Backend
        backendRequest.end();

        // req.on('close', () => {
        //     console.log('Client Connection Closed.');
        //     backendRequest.abort();
        // });

});


const port = parseInt(process.env.PORT) || 8080;
app.listen(port, () => {
  console.log(`aigw-llm-router: listening on port ${port}`);
});
