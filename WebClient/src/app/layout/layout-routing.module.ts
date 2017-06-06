import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import {LayoutSidenavRoutes} from "./sidenav/sidenav.routing";

@NgModule({
	imports: [
		RouterModule.forChild([
			// ...LayoutFooterRoutes,
			// ...LayoutHeaderRoutes,
			...LayoutSidenavRoutes,
		]),
	],
	exports: [
		RouterModule,
	],
})

export class LayoutRoutingModule { }
