import { Component, OnInit } from '@angular/core';
import {VideoService} from "../../shared/services/video.service";
import {Video} from "../../models/video";

@Component({
	selector: 'app-video-list',
	templateUrl: './video-list.component.html',
	styleUrls: ['./video-list.component.css']
})
export class VideoListComponent implements OnInit {

	list: Array<Video> = new Array<Video>();

	constructor(private _videoService:VideoService) {
		this._videoService.progressSubject.subscribe(list => {
			this.list = list
		})
	}

	ngOnInit() {
		this._videoService.load();
	}

}
