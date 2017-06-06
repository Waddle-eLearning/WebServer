import {Component, Input, OnInit} from "@angular/core";
import { VgAPI } from 'videogular2/core';
import { TimerObservable } from 'rxjs/observable/TimerObservable';
import { Subscription } from 'rxjs';
import {Video} from "../../models/video";
import {ActivatedRoute, Params} from "@angular/router";
import {VideoService} from "../../shared/services/video.service";

@Component({
	selector: 'app-video-page',
	templateUrl: './video-page.component.html',
	styleUrls: ['./video-page.component.css']
})

export class VideoPageComponent implements OnInit {

	api: VgAPI;

	video:Video;
	id: string;

	constructor(private videoService: VideoService,
				private route: ActivatedRoute) { }

	onPlayerReady(api:VgAPI) {
		this.api = api;
	}

	ngOnInit(): void {
		this.route.params.subscribe(params => {
			this.id = params['id']; // (+) converts string 'id' to a number
			console.log(this.id);

			this.videoService.getVideo(this.id).subscribe(
				(video:Video) => {
					this.video = video;
					console.log(this.video);
				},
				error => {
					console.log(error);
				}
			);
		});
	}

}
