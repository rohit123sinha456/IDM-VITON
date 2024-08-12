from flask import Flask, flash, request, redirect, url_for,jsonify
from io import BytesIO
from flask_cors import CORS
from PIL import Image
import base64
import io
from processingImage import start_tryon
#SHA256(quleep_virtual_tryon)
TOKEN="7c5fb03b087bbec4932383d6f2116690884ead7f6dfb9ce72f2f1d4d39aaf55d"


app = Flask(__name__)
CORS(app)

@app.route('/api/v1')
def main():
    return "API for Detecting Walls and Floors in an Image"

@app.route('/api/v1/infer', methods = ['POST'])
def success():
    prompt = ""
    is_checked = True
    is_checked_crop = False
    denoise_steps = 30
    seed = 42
    access_token = request.headers.get('auth-token')
    if(access_token != TOKEN):
        return jsonify({"data":"Invalid auth-token in Header"}),401

    if request.method == 'POST':
        requestjson = request.json
        humanimgbase64 = requestjson.get('humanimg')
        designimgbase64 = requestjson.get('designimg')
        if humanimgbase64 is None or designimgbase64 is None:
            return jsonify({"data":"No file/mode Sent"}),400
        try:
            humanimgbase64_data = humanimgbase64.split(',')[1]
            imgs = Image.open(BytesIO(base64.b64decode(humanimgbase64_data)))
        except Exception as e:
            return jsonify({"data":str(e),"image_name":"Human Image"}),400
        
        try:
            designimgbase64_data = humanimgbase64.split(',')[1]
            garm_img = Image.open(BytesIO(base64.b64decode(designimgbase64_data)))
        except Exception as e:
            return jsonify({"data":str(e),"image_name":"Human Image"}),400
        
        output_image,mask = start_tryon(imgs,garm_img,prompt,is_checked,is_checked_crop,denoise_steps,seed)

        buffered = io.BytesIO()
        if imgs.mode == 'RGBA':
            imgs = imgs.convert('RGB')
        output_image.save(buffered, format="JPEG") 
        imgencode = base64.b64encode(buffered.getvalue()).decode("utf-8")
        return imgencode
    

if __name__ == '__main__':
	app.run(debug=True)