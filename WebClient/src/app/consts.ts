import {Headers} from "@angular/http";


export class URLS {
	static readonly  api = "api/v1/";

	public static readonly login        = URLS.api + "auth/login";
	public static readonly register     = URLS.api + "auth/register";
	public static readonly renew        = URLS.api + "auth/renew";
	public static readonly validate     = URLS.api + "auth/validate";

	public static readonly me           = URLS.api + "users/me";

	public static readonly fileUpload   = URLS.api + "upload";

	public static readonly videos       = URLS.api + "videos";

	public static  video(id:string) :string {
		return URLS.videos + "/" + id;
	}
}

export class Constans {
	static readonly  BytesPerPart = 1024 * 1024;
}

export function headers() {
	var headers = new Headers();
	headers.append('Content-Type', 'application/json');
	// var basicAuth =  localStorage.getItem('AuthKey');
	// headers.append('Authorization', basicAuth);

	return headers;
}
