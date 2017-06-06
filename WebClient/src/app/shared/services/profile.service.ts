import { Injectable } from '@angular/core';
import {Subject} from "rxjs/Subject";
import {Video} from "../../models/video";
import {AuthHttp} from "angular2-jwt";
import {URLS} from "../../consts";

@Injectable()
export class ProfileService {

	public progressSubject: Subject<Array<Video>> = new Subject<Array<Video>>();

	constructor(private authHttp: AuthHttp) { }

	load() {

		this.authHttp.get(URLS.videos)
			.map(res => res.json())
			.subscribe(
				(videos: Array<Video>) => {
					console.log(videos);
					this.progressSubject.next(videos);
				},
				error => {
					console.log(error);
				}
			);
	}

	getVideo(id: string){
		let url = URLS.video(id);
		console.log(url);
		return this.authHttp.get(url)
			.map(res => {
				return res.json()
			});
	}

}
