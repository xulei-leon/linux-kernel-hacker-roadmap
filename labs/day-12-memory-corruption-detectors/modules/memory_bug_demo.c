#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/slab.h>
#include <linux/string.h>

static bool trigger_oob;
module_param(trigger_oob, bool, 0644);
MODULE_PARM_DESC(trigger_oob, "Dangerous: write one byte beyond allocation");

static bool trigger_uaf;
module_param(trigger_uaf, bool, 0644);
MODULE_PARM_DESC(trigger_uaf, "Dangerous: write after kfree");

static bool trigger_leak;
module_param(trigger_leak, bool, 0644);
MODULE_PARM_DESC(trigger_leak, "Leak one allocation for kmemleak practice");

static char *leaked;

static int __init memory_bug_demo_init(void)
{
	char *buf;

	pr_info("memory_bug_demo: loaded oob=%d uaf=%d leak=%d\n",
		trigger_oob, trigger_uaf, trigger_leak);

	buf = kmalloc(16, GFP_KERNEL);
	if (!buf)
		return -ENOMEM;

	memset(buf, 'A', 16);

	if (trigger_oob) {
		pr_alert("memory_bug_demo: writing past 16-byte buffer for detector practice\n");
		buf[16] = 'X';
	}

	if (trigger_uaf) {
		kfree(buf);
		pr_alert("memory_bug_demo: writing after free for detector practice\n");
		buf[0] = 'U';
		return 0;
	}

	kfree(buf);

	if (trigger_leak) {
		leaked = kmalloc(128, GFP_KERNEL);
		if (!leaked)
			return -ENOMEM;
		strscpy(leaked, "intentional memory_bug_demo leak", 128);
		pr_info("memory_bug_demo: leaked allocation=%p for kmemleak practice\n", leaked);
	}

	return 0;
}

static void __exit memory_bug_demo_exit(void)
{
	if (leaked) {
		kfree(leaked);
		pr_info("memory_bug_demo: freed intentional leak on unload\n");
	}
	pr_info("memory_bug_demo: unloaded\n");
}

module_init(memory_bug_demo_init);
module_exit(memory_bug_demo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("linux-kernel-hacker-roadmap");
MODULE_DESCRIPTION("Day 12 memory detector demo module");
