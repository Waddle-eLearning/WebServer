import {VideoService} from "./video.service";
import {UploadService} from "./upload.service";

export * from "./video.service";
export * from "./upload.service";

export const Services = [
	VideoService,
	UploadService
];
