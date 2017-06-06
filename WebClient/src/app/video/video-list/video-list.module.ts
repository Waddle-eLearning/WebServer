import { NgModule } from "@angular/core";

import {VideoListComponent} from "./video-list.component";
import {SharedModule} from "../../shared/shared.module";
import {VideoListItemComponent} from "./video-list-item/video-list-item.component";

@NgModule({
	imports: [
		SharedModule
	],
	declarations: [
		VideoListComponent,
		VideoListItemComponent
	]
})
export class VideoListModule {
}
