# Database 3 (GA5) · Portfolio project guide

The existing Project 03 has been upgraded, not duplicated. The full site is included.

- Homepage card uses `assets/database-project-cover.webp`, a composite of **actual** screenshots from the 2025 GA5 report.
- Detail page: `projects/maintenance-database.html`.
- Interactive browser reconstruction: `database-demo/index.html`. Open in Chrome to filter **nine submitted sample request rows**; this is not a database server.
- `database-code/original-submitted-ga5.sql` preserves the supplied SQL code with explanatory comments added on top.
- `database-code/portfolio-replay.sql` is a separately labelled, independently runnable example for an empty local MySQL instance.
- Source screenshot files are extracted from the submitted academic report.

Important notes: the submitted SQL has an invalid `JOIN` reference to `MaintenanceRequests.location_id`, which is not defined. The only defined foreign key in the submitted script links `Assets.location_id` to `Locations.location_id`. The report screenshot and sample source SQL may show different numbers of records due to repeated inserts. This portfolio demonstrates the original nine INSERT records and does not claim to be live municipal data.

**Privacy:** no original report with student number or signature is included. Do not publish the full academic report publicly without redacting it.


## GA9 additional project evidence (October 2026)
- `projects/online-store-database.html` expands Project 04 from the GA9 report and transcript.
- `assets/online-store-ga9-cover.webp` uses excerpts from actual 2025 screenshot results, with identifying schema names excluded.
- `assets/ga9-cte-result.webp`, `assets/ga9-stock-result.webp`, `assets/ga9-discount-result.webp` are cropped genuine report evidence.
- `database-code/online-store-portfolio-replay.sql` is a NEW anonymised MySQL 8 demonstration built for public portfolio use, **not** the student's original transcript.
- `online-store-demo/index.html` is an interactive JavaScript simulation, NOT a connected MySQL app.
- `database-code/cape-town-maintenance-original.drawio` is the original GA5 drawing file.
- `assets/cape-town-drawio-diagram.webp` redraws the original diagram for clarity. Its conceptual relationship labels are not all literal FKs in the GA5 SQL schema.

The original coursework reports and SQL transcript include an identifying student-number-based naming convention and are intentionally NOT published as full files. Keep your complete original reports privately.
