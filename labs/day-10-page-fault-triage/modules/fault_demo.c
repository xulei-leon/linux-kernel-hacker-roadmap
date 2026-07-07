#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>

static bool trigger_null;
module_param(trigger_null, bool, 0644);
MODULE_PARM_DESC(trigger_null, "Dangerous: trigger a NULL pointer write during module load");

static int __init fault_demo_init(void)
{
	pr_info("fault_demo: loaded, trigger_null=%d\n", trigger_null);

	if (trigger_null) {
		volatile int *ptr = NULL;

		pr_alert("fault_demo: about to write through NULL pointer for Day 10 oops practice\n");
		*ptr = 1;
	}

	pr_info("fault_demo: safe load complete; reload with trigger_null=1 only in a disposable VM\n");
	return 0;
}

static void __exit fault_demo_exit(void)
{
	pr_info("fault_demo: unloaded\n");
}

module_init(fault_demo_init);
module_exit(fault_demo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("linux-kernel-hacker-roadmap");
MODULE_DESCRIPTION("Day 10 page fault triage demo module");

