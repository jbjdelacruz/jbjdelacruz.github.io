---
permalink: /
title: "About"
author_profile: true
redirect_from: 
  - /about/
  - /about.html

---

<p>
A composer’s setlist is a deliberate arrangement of musical works that shapes a performance or album. In the same way, <i>The Data Setlist</i>—a curated collection of projects—showcases my problem-solving, creativity, and storytelling with data.
</p>

<p>
Welcome! I’m Bon, a Statistics graduate from the University of the Philippines and a freelance Statistician specializing in research-oriented data analysis and consultancy. 
</p>

<p>
During my undergraduate years, I co-directed a national Statistics summit with over 250 participants, led publicity campaigns to promote statistical literacy, and competed in data challenges that included analyzing 60,000+ urban tree records for city planning and applying machine learning techniques to health survey data.
</p>

<p>
Professionally, I worked as an Operations Associate at a New York–based market research SaaS startup, where I built KPI dashboards, prepared datasets for product development, and contributed to SEO strategies that significantly boosted website traffic.
</p>

<p>
Explore to see how I compose meaningful insights from raw data.
</p>

<!-- <p>
  <strong>Skills:</strong> R · SQL · Tableau · Excel
</p> -->


## Featured

<div class="projects-grid about-projects">
  {% assign featured_projects = site.portfolio | where: "featured", true | sort: "date" | reverse | slice: 0, 2 %}
  {% for project in featured_projects %}
    <div class="about-project-card">
      <a href="{{ project.url | relative_url }}">
        {% if project.thumbnail %}
          <img src="{{ project.thumbnail | relative_url }}" alt="{{ project.title }}">
        {% endif %}
        <h3>{{ project.title }}</h3>
      </a>
    </div>
  {% endfor %}
</div>


<div class="see-all-projects">
  <a href="{{ '/portfolio/' | relative_url }}">See all projects →</a>
</div>