import {Injectable} from '@angular/core';
import {AuthHttp} from "angular2-jwt";
import {Constans, URLS} from "../../consts";
import {ParallelHasher} from "ts-md5/dist/parallel_hasher";
import {Subject} from "rxjs/Subject";
import {unescapeIdentifier} from "@angular/compiler";
import {forEach} from "@angular/router/src/utils/collection";

@Injectable()
export class UploadService {

	private uploads = new Map<string,Upload>();


	private hasher = new ParallelHasher('/assets/md5_worker.js');

	public progressArraySubject: Subject<Array<Progress>> = new Subject<Array<Progress>>();
	public progressMap: Map<string,Progress> = new Map<string,Progress>();

	public progressSubject: Subject<Progress> = new Subject<Progress>();

	constructor(private authHttp: AuthHttp) {
		this.progressSubject.subscribe(progress => {
			this.progressMap.set(progress.name, progress);

			var progressArray = new Array<Progress>();
			this.progressMap.forEach( value => {
				progressArray.push(value);
			});

			this.progressArraySubject.next(progressArray);
			// this.uploadNext();
		});
	}

	public uploadFile(file: File) {
		let upload = new Upload(file,
								this.hasher,
								this.authHttp,
								this.progressSubject);

		upload.start();
		this.uploads.set(upload.fileName, upload);
	}

	private uploadNext(){
		this.uploads.forEach(upload => {
			if (!upload.isFinished() && !upload.paused) {
				upload.start();
				return;
			}
		})
	}

	pauseUpload(uploadName: string){
		let upload = this.uploads.get(uploadName);

		if (upload) {
			upload.pause();
		}
	}

	resumeUpload(uploadName: string){
		let upload = this.uploads.get(uploadName);

		if (upload) {
			upload.resume();
		}
	}

	removeUpload(uploadName: string){
		let upload = this.uploads.get(uploadName);
		if (upload) {
			upload.pause();
		}

		this.progressMap.delete(uploadName);
		this.uploads.delete(uploadName);
	}

}

class Part{
	hash: string;

	constructor(public file:        File,
	            public partNr:      number,
	            public name:        string,
	            public type:        string,
	            public partCount:   number,
	            public size:        number,
	            public start:       number,
	            public end:         number){
	}

	getBlob():Blob{
		return this.file.slice(this.start, this.end)
	}
}

class Upload{
	fileName:   string;
	type:       string;
	size:       number;
	partCount:  number;
	paused:     boolean = true;

	progress:   number = 0;

	failcount = 0;

	//the parts to be uploaded
	private partsQue = new Map<number,Part>();

	// the uploaded Parts
	private finishedParts = new Map<number,Part>();

	//the currently uplaoding parts
	private uploadingParts = new Map<number,Part>();

	private hashSubject: Subject<Part> = new Subject<Part>();

	constructor(private file: File,
	            private hasher: ParallelHasher,
	            private authHttp: AuthHttp,
	            private progressSubject: Subject<Progress>){

		this.fileName   = encodeURIComponent(file.name);
		this.type       = file.type;
		this.size       = file.size;

		this.hashSubject.subscribe(part => {
			this.addPartToQue(part);
			this.info();
			this.uploadNextPartOfQue();
		});

		var bytesPerPart = Constans.BytesPerPart;
		this.partCount = Math.max(Math.ceil(file.size / bytesPerPart ), 1);

		while (this.partCount > 512) {
			bytesPerPart = bytesPerPart * 2;
			this.partCount = Math.max(Math.ceil(file.size / bytesPerPart ), 1);
			console.log("partCount: "+ this.partCount + " BytesPerPart: "+ bytesPerPart)
		}

		for (let _i = 0; _i < this.partCount; _i++) {
			console.log(_i);
			let part = new Part(file,
				_i,
				this.fileName,
				this.type,
				this.partCount,
				this.size,
				_i * bytesPerPart,
				_i * bytesPerPart + bytesPerPart);
			// console.log(partNumber);
			this.hashPart(part);
		}


	}

	private info() {
		let info =
					"partCount: "           + this.partCount +
					" uploadingPartsQue: "   + this.partsQue.size +
					" uploadedParts: "      + this.finishedParts.size +
					" uploadingParts: "     + this.uploadingParts.size +
					" progress: "           + this.progress;

		// console.log(info);
	}

	private hashPart(part: Part) {

		let hashSubject = this.hashSubject;

		this.hasher.hash(part.getBlob()).then(function(result) {
			part.hash = result;
			hashSubject.next(part);
			console.log(part.partNr);
		});
	}

	calculateProgress(){
		this.progress = (this.finishedParts.size / this.partCount) * 100;
		this.progressSubject.next(
			new Progress(this.fileName,
				this.progress,
				this.paused,
				this.isFinished())
		);
		this.info();
	}

	private addPartToQue(part: Part){
		this.partsQue.set(part.partNr, part);
		this.calculateProgress();
	}

	private finishPart(part: Part){
		this.finishedParts.set(part.partNr, part);
		this.partsQue.delete(part.partNr);
		this.uploadingParts.delete(part.partNr);
		this.calculateProgress();
		this.uploadNextPartOfQue();
	}

	private movePartToUploading(part: Part){
		this.uploadingParts.set(part.partNr, part);
		this.partsQue.delete(part.partNr);
	}

	private movePartBackToQue(part: Part){
		this.partsQue.set(part.partNr, part);
		this.uploadingParts.delete(part.partNr);
	}

	private getNextPartFromQue():Part {
		if (!this.paused) {
			let nextPart = this.partsQue.values().next().value;

			if (nextPart){
				return nextPart;
			}
		}
		return null;
	}

	start(){
		this.resume();
	}

	pause(){
		this.paused = true;
		this.calculateProgress();
	}

	resume(){
		this.failcount = 0;
		this.paused = false;
		this.calculateProgress();
		this.uploadNextPartOfQue();
		this.uploadNextPartOfQue();
	}

	isFinished():boolean{
		return this.partsQue.size == 0;
	}

	abledToUploadNext():boolean{
		return !this.paused && this.uploadingParts.size < 1;
	}

	private uploadNextPartOfQue(){
		if ( this.abledToUploadNext() ){
			let nextPart = this.partsQue.values().next().value;

			if (nextPart) {
				this.movePartToUploading(nextPart);
				this.uploadPart(nextPart);
			}
		}
	}

	private uploadPartFinished(part: Part, uploadResonse: UploadResonse){
		this.finishPart(part);
		uploadResonse.parts.forEach(partResonse => {

			let finishedpart = this.partsQue.get(partResonse.partNr);

			if ( finishedpart && finishedpart.hash == partResonse.hash) {
					console.log("finishedpart");
					this.finishPart(finishedpart);
			}
		});
	}

	private uploadPartFailed(part: Part){
		this.failcount ++;
		if (this.failcount > 10) {
			this.pause();
		}
		this.movePartBackToQue(part);
	}

	private uploadPart(part: Part) {

		let url = URLS.fileUpload +
			"?slicePartNr=" + part.partNr +
			"&sliceName="   + part.name +
			"&sliceSize="   + part.size +
			"&sliceType="   + part.type +
			"&sliceCount="  + part.partCount +
			"&sliceHash="   + part.hash;

		this.authHttp.post(url ,part.getBlob())
			.map(res => res.json())
			.subscribe(
				(uploadResonse: UploadResonse) => {
					console.log(uploadResonse.success);
					if (uploadResonse.success){
						this.uploadPartFinished(part, uploadResonse);
					} else {
						this.uploadPartFailed(part);
					}
				},
				error => {
					console.log(error);
					this.uploadPartFailed(part);
				}
			);
	}

}

class UploadResonse{
	success: boolean;
	name: string;
	parts: Array<PartResonse>;
}

class PartResonse {
	hash: string;
	partNr: number;
}

export class Progress {
	constructor(public name:string,
	            public progress: number,
				public paused: boolean,
				public finished: boolean)
	{}

}
