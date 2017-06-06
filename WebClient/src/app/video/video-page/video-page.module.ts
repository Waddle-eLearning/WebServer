import { NgModule } from "@angular/core";
import { CommonModule } from "@angular/common";

import { VgCoreModule } from "videogular2/core";
import { VgControlsModule } from "videogular2/controls";
import { VgOverlayPlayModule } from "videogular2/overlay-play";
import { VgBufferingModule } from "videogular2/buffering";
import { VgStreamingModule } from "videogular2/streaming";
import { FormsModule } from "@angular/forms";
import {VideoPageComponent} from "./video-page.component";
import {SharedModule} from "../../shared/shared.module";

@NgModule({
	imports: [
		CommonModule,
		FormsModule,
		VgCoreModule,
		VgControlsModule,
		VgOverlayPlayModule,
		VgBufferingModule,
		VgStreamingModule,
		SharedModule
	],
	declarations: [ VideoPageComponent ]
})
export class VideoPageModule {
}
