faq.component.ts

```
// dealing with anchor links in Angular :-/
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router, NavigationEnd } from '@angular/router';

@Component({
  selector: 'app-faq',
  templateUrl: './faq.component.html',
  styleUrls: ['./faq.component.css']
})
export class FaqComponent implements OnInit {

  constructor(private route: ActivatedRoute, private router: Router) {}

  scrollToFragment(f: string) {
    const element = document.querySelector('#' + f);
    if (element) {
      // element.scrollIntoView(true);
      window.scroll({top: element['offsetTop'] - 50, behavior: 'smooth'});
    }
  }

  ngOnInit() {
    this.router.events.subscribe(s => {
      if (s instanceof NavigationEnd) {
        const tree = this.router.parseUrl(this.router.url);
        this.scrollToFragment(tree.fragment);
      }
    });
  }

  onAnchorClick() {
    this.route.fragment.subscribe (f => {
      this.scrollToFragment(f);
    });
  }

}

```

faq.component.html

```
<div class="container">
  <h2>FAQ</h2>

  <div class="row">
    <ul>
      <li><a [routerLink]="['/ayuda']" fragment="section1" (click)="onAnchorClick()">What is this?</a></li>
      <li><a [routerLink]="['/ayuda']" fragment="section2" (click)="onAnchorClick()">What is that?</a></li>
      <li><a [routerLink]="['/ayuda']" fragment="section3" (click)="onAnchorClick()">What are these?</a></li>
      <li><a [routerLink]="['/ayuda']" fragment="section3" (click)="onAnchorClick()">What are those?</a></li>
    </ul>
  </div>
  
  <!-- section 1 -->
  <a id="section1"></a>
  <div class="row">
    <div class="col">
      <div class="card">
        <div class="card-header">
          <h5 class="mb-0">
              <i class="fa fa-info-circle" aria-hidden="true"></i> What is this?
          </h5>
        </div>
        <div>
          <div class="card-body">
            <p>
              In maximus, sapien vel facilisis interdum, lectus velit maximus dolor, 
              et posuere sem ligula a magna. Maecenas feugiat, est eu malesuada laoreet, 
              erat nisl dapibus urna, quis aliquam metus lectus eu sem. Donec non pellentesque 
              neque. Vestibulum tempor sapien non mattis sagittis. Suspendisse tempus sodales 
              posuere. Mauris ac congue est. Aenean tincidunt placerat enim, vel lacinia metus 
              porttitor eget. Cras eu pharetra nibh. Curabitur imperdiet est ut tellus cursus, 
              quis efficitur nisl varius.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <!-- another sections here -->
</div>
```
