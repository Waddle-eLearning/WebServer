import { Component, OnInit } from '@angular/core';
import {Progress, UploadService} from "../../shared/services/upload.service";
import {AuthHttp} from "angular2-jwt";

@Component({
	selector: 'app-upload',
	templateUrl: './upload.component.html',
	styleUrls: ['./upload.component.css']
})
export class UploadComponent {

	isDraged: boolean;
	progress =  Array<Progress>();

	constructor( private _uploadService: UploadService ) {
		this._uploadService.progressArraySubject.subscribe(progress => {
			// console.log(progress);
			// this.progress = progress;

			progress.forEach(p =>{
				let found = false;
				this.progress.forEach(thisprogress =>{
					if ( p.name == thisprogress.name) {
						found = true;
						thisprogress.progress   = p.progress;
						thisprogress.paused     = p.paused;
						thisprogress.finished   = p.finished;
					}
				});

				if (!found) {
					this.progress.push(p);
				}
			});
		});
	}

	handleDrop(e) {

		this.isDraged = false;

		let files:File = e.dataTransfer.files;

		Object.keys(files).forEach((key) => {

			if(files[key].type.startsWith("audio/",0) ||
				files[key].type.startsWith("video/",0) ||
				files[key].type.startsWith("image/",0)) {
				this._uploadService.uploadFile(files[key]);
			}
			else {
				alert("File must be a PNG or JPEG!");
			}
		});
		return false;
	}

	dragleave(){
		this.isDraged = false;
		return false;
	}
	dragend(){
		this.isDraged = false;
		return false;
	}
	dragover(){
		this.isDraged = true;
		return false;
	}
	pauseUpload(uploadName: string){
		this._uploadService.pauseUpload(uploadName);
	}

	resumeUpload(uploadName: string){
		this._uploadService.resumeUpload(uploadName);
	}
	removeUpload(uploadName: string){
		this._uploadService.removeUpload(uploadName);
	}

}
