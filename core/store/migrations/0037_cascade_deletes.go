package migrations

import (
	"gorm.io/gorm"
)

const up37 = `
	ALTER TABLE jobs DROP CONSTRAINT jobs_cron_spec_id_fkey,
		DROP CONSTRAINT jobs_direct_request_spec_id_fkey,
		DROP CONSTRAINT jobs_vrf_spec_id_fkey,
		DROP CONSTRAINT jobs_keeper_spec_id_fkey,
		DROP CONSTRAINT jobs_webhook_spec_id_fkey,
		DROP CONSTRAINT jobs_flux_monitor_spec_id_fkey;
	ALTER TABLE jobs ADD CONSTRAINT jobs_cron_spec_id_fkey FOREIGN KEY (cron_spec_id) REFERENCES cron_specs(id) ON DELETE CASCADE,
		ADD CONSTRAINT jobs_direct_request_spec_id_fkey FOREIGN KEY (direct_request_spec_id) REFERENCES direct_request_specs(id) ON DELETE CASCADE,
		ADD CONSTRAINT jobs_vrf_spec_id_fkey FOREIGN KEY (vrf_spec_id) REFERENCES vrf_specs(id) ON DELETE CASCADE,
		ADD CONSTRAINT jobs_keeper_spec_id_fkey FOREIGN KEY (keeper_spec_id) REFERENCES keeper_specs(id) ON DELETE CASCADE,
		ADD CONSTRAINT jobs_webhook_spec_id_fkey FOREIGN KEY (webhook_spec_id) REFERENCES webhook_specs(id) ON DELETE CASCADE,
		ADD CONSTRAINT jobs_flux_monitor_spec_id_fkey FOREIGN KEY (flux_monitor_spec_id) REFERENCES flux_monitor_specs(id) ON DELETE CASCADE;
`

const down37 = `
	ALTER TABLE jobs
		DROP CONSTRAINT jobs_cron_spec_id_fkey,
		DROP CONSTRAINT jobs_direct_request_spec_id_fkey,
		DROP CONSTRAINT jobs_vrf_spec_id_fkey,
		DROP CONSTRAINT jobs_keeper_spec_id_fkey,
		DROP CONSTRAINT jobs_webhook_spec_id_fkey,
		DROP CONSTRAINT jobs_flux_monitor_spec_id_fkey;
	ALTER TABLE jobs
		ADD CONSTRAINT jobs_cron_spec_id_fkey FOREIGN KEY (cron_spec_id) REFERENCES cron_specs(id),
		ADD CONSTRAINT jobs_direct_request_spec_id_fkey FOREIGN KEY (direct_request_spec_id) REFERENCES direct_request_specs(id),
		ADD CONSTRAINT jobs_vrf_spec_id_fkey FOREIGN KEY (vrf_spec_id) REFERENCES vrf_specs(id),
		ADD CONSTRAINT jobs_keeper_spec_id_fkey FOREIGN KEY (keeper_spec_id) REFERENCES keeper_specs(id),
		ADD CONSTRAINT jobs_webhook_spec_id_fkey FOREIGN KEY (webhook_spec_id) REFERENCES webhook_specs(id),
		ADD CONSTRAINT jobs_flux_monitor_spec_id_fkey FOREIGN KEY (flux_monitor_spec_id) REFERENCES flux_monitor_specs(id);
`

func init() {
	Migrations = append(Migrations, &Migration{
		ID: "0037_cascade_deletes",
		Migrate: func(db *gorm.DB) error {
			return db.Exec(up37).Error
		},
		Rollback: func(db *gorm.DB) error {
			return db.Exec(down37).Error
		},
	})
}
